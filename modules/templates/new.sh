# shellcheck shell=bash disable=SC2154 # DEFAULT_REPO vem do new.nix
# new: cria um projeto a partir dos modelos do devenv (docs/templates.md).

usage() {
  cat <<'USAGE'
uso: new <linguagem> <pasta> [tipo] [opções do copier]

  new python meu-site fastapi-htmx
  new python minha-lib                  pergunta o tipo e o resto
  new python dados data --defaults      sem perguntas, tudo no padrão
  new python api api -d postgres=true   responde uma pergunta direto

linguagens e tipos:
  python  lib api llm data ml fastapi-htmx django streamlit
  go      cli service htmx
  rust    bin lib
  elixir  phoenix

O projeto sai pronto: git com o primeiro commit, flake.lock com o mesmo nixpkgs do devenv,
dependências travadas e hooks instalados. Depois: cd <pasta> e `just`.
Os modelos vêm de $DEVENV_REPO (padrão: ~/devenv).
USAGE
}

die() {
  echo "new: $*" >&2
  exit 1
}

# Versão do gerador do Phoenix (mix phx.new). O Dependabot atualiza o Phoenix do projeto depois.
PHX_NEW_VERSION="${DEVENV_PHX_NEW_VERSION:-1.8.16}"

# Phoenix: o próprio `mix phx.new` gera o app numa pasta temporária, e ele entra no projeto sem
# sobrescrever os nossos arquivos (AGENTS.md e .gitignore ganham o conteúdo dele no fim).
phoenix() {
  local app db tmp f
  app="$(sed -n 's/^project_name: //p' .copier-answers.yml | tr - _)"
  db=sqlite3
  grep -q '^postgres: true' .copier-answers.yml && db=postgres
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2016 # os $1.. são do bash -c, de propósito
  nix develop --command bash -euo pipefail -c '
    mix local.hex --force --if-missing
    mix local.rebar --force --if-missing
    mix archive.install hex phx_new "$1" --force
    mix phx.new "$2/$3" --app "$3" --database "$4" --no-install
  ' _ "${PHX_NEW_VERSION}" "${tmp}" "${app}" "${db}"
  for f in AGENTS.md .gitignore; do
    if [ -f "${tmp}/${app}/${f}" ]; then
      printf '\n' >>"${f}"
      cat "${tmp}/${app}/${f}" >>"${f}"
      rm "${tmp}/${app}/${f}"
    fi
  done
  cp -r --update=none "${tmp}/${app}/." .
  rm -rf "${tmp}"
  git add --all
  nix develop --command bash -euo pipefail -c '
    mix deps.get
    mix assets.setup || echo "new: não deu para baixar o Tailwind e o esbuild agora; rode just setup depois" >&2
    if grep -q "^docker: true" .copier-answers.yml; then mix phx.gen.release --docker; fi
    mix format
  '
}

case "${1:-}" in
  "" | -h | --help | help)
    usage
    exit 0
    ;;
esac
[ $# -ge 2 ] || die "faltou a pasta (veja: new --help)"

repo="${DEVENV_REPO:-${DEFAULT_REPO}}"
[ -f "${repo}/copier.yml" ] || die "não achei os modelos em ${repo} (defina DEVENV_REPO)"

lang="$1"
dest="$2"
shift 2
kind=""
if [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; then
  kind="$1"
  shift
fi
[ -e "${dest}" ] && die "${dest} já existe"

args=(copy --quiet --trust --vcs-ref HEAD --data "lang=${lang}")
[ -n "${kind}" ] && args+=(--data "${lang}_kind=${kind}")
author_name="$(git config user.name || true)"
author_email="$(git config user.email || true)"
[ -n "${author_name}" ] && args+=(--data "author_name=${author_name}")
[ -n "${author_email}" ] && args+=(--data "author_email=${author_email}")
if [ "${lang}" = go ]; then
  # Para o caminho do módulo (github.com/<usuário>/<projeto>).
  github_user="$(git config github.user || gh api user --jq .login 2>/dev/null || true)"
  [ -n "${github_user}" ] && args+=(--data "github_user=${github_user}")
fi

copier "${args[@]}" "$@" "${repo}" "${dest}"
cd "${dest}" || exit 1
kind="$(sed -n "s/^${lang}_kind: //p" .copier-answers.yml)"

git init --quiet --initial-branch main
# O mesmo nixpkgs do devenv: nada novo para baixar. `nix flake update` atualiza depois.
jq '{nodes: {nixpkgs: .nodes[.nodes.root.inputs.nixpkgs], root: {inputs: {nixpkgs: "nixpkgs"}}}, root: "root", version: 7}' \
  "${repo}/flake.lock" >flake.lock
git add --all # o Nix só enxerga os arquivos que estão no git

echo "new: travando as dependências..."
case "${lang}" in
  python) nix develop --command uv lock --quiet ;;
  go) nix develop --command go mod tidy ;;
  rust) nix develop --command cargo generate-lockfile --quiet ;;
  elixir) phoenix ;;
esac
nix develop --command lefthook install >/dev/null

git add --all
git commit --quiet --no-verify --message "chore: projeto criado com o devenv (${lang}${kind:+/${kind}})"
if command -v direnv >/dev/null 2>&1; then
  direnv allow
fi

echo "pronto: cd ${dest} && just"
