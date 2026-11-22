#!/usr/bin/env bash
# Confere o que o bootstrap deve deixar pronto. Roda no CI depois do ./bootstrap.sh.
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

# check <o que> <comando...>: imprime ok ou FALTA e marca a falha.
check() {
  local what="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "ok: ${what}"
  else
    echo "FALTA: ${what}" >&2
    fail=1
  fi
}

for cmd in chezmoi metapac just cz; do
  check "${cmd} no PATH" command -v "${cmd}"
done
check "${HOME}/.config/metapac -> ${repo}/packages" test "$(readlink -f "${HOME}/.config/metapac")" = "${repo}/packages"
check "asm-lsp em ${HOME}/.local/bin (chezmoi)" test -x "${HOME}/.local/bin/asm-lsp"
check "rustup com rustc e rust-analyzer" rustup which rust-analyzer

# Com o grupo terminal.
if command -v ghostty >/dev/null; then
  check "config do Ghostty" ghostty +validate-config --config-file="${HOME}/.config/ghostty/config"
  # Sem pipe direto: com pipefail, o grep -q sai cedo e o fc-list morre de SIGPIPE, o que conta como falha.
  fonts="$(fc-list : family)"
  check "fonte BlexMono Nerd Font" grep -q "BlexMono Nerd Font" <<<"${fonts}"
  check "paletas dos temas batem com o gerador" python3 "${repo}/temas/gerar.py" --check
  check "tema inicial do Ghostty" test -f "${HOME}/.config/ghostty/themes/noctalia"
fi

# Com o grupo shell: a config carrega sem erro e o hook do fisher instalou o tide.
if command -v fish >/dev/null; then
  # shellcheck disable=SC2016 # a variável é do fish, não do bash
  check "config do fish sem erro" fish -i -c 'test "$fish_key_bindings" = fish_vi_key_bindings'
  check "tide pelo fisher" fish -c 'type -q tide'
  check "comando theme" fish -c 'type -q theme'
  # Ctrl+G: com o fzf trocado por um filtro (que falha se a lista vier vazia) e o zoxide vazio, o fd tem que
  # achar uma pasta do ~ para entrar.
  # shellcheck disable=SC2016 # as variáveis são do fish, não do bash
  check "Ctrl+G lista pastas e entra" fish -c 'set -x _ZO_DATA_DIR (mktemp -d)
    function fzf; command fzf --filter=/ | read -l first; and echo $first; end
    function commandline; end; cd /; _devenv_jump; test "$PWD" != /'
fi

# Com o grupo desktop: as configs do niri e do Noctalia valem (o Noctalia só avisa, então aviso conta como falha).
if command -v niri >/dev/null; then
  check "config do niri" niri validate -c "${HOME}/.config/niri/config.kdl"
  check "config do Noctalia sem aviso" sh -c "noctalia config validate '${HOME}/.config/noctalia/config.toml' 2>&1 | grep -q 'valid\$'"
fi

check "${HOME}/Pictures/Wallpapers -> wallpapers/" test "$(readlink -f "${HOME}/Pictures/Wallpapers")" = "${repo}/wallpapers"

# Com o grupo teclado: o Vial e a regra udev que deixa ele falar com o Corne.
if command -v Vial >/dev/null; then
  check "regra udev do Vial" test -f /usr/lib/udev/rules.d/59-vial.rules
fi

# Com o grupo editor: o hook do bob deixou o nightly em uso.
if command -v bob >/dev/null; then
  check "Neovim nightly pelo bob" test -x "${HOME}/.local/share/bob/nvim-bin/nvim"
fi

# Agentes: instruções, settings mesclado, statusline e MCP.
check "${HOME}/.claude/CLAUDE.md -> agents/AGENTS.md" test "$(readlink -f "${HOME}/.claude/CLAUDE.md")" = "${repo}/agents/AGENTS.md"
check "settings do Claude com sandbox e statusline" jq -e '.sandbox.enabled and .statusLine.command' "${HOME}/.claude/settings.json"
check "MCP context7 no ~/.claude.json" jq -e '.mcpServers.context7.url' "${HOME}/.claude.json"
check "${HOME}/.claude.json só para o dono (0600)" test "$(stat -c %a "${HOME}/.claude.json")" = 600
# O sandbox só libera escrita em pasta que já existe: o chezmoi cria os caches vazios (.keep).
for d in .cache/go-build go/pkg/mod .cargo/git; do
  check "cache ${HOME}/${d} existe para o sandbox" test -d "${HOME}/${d}"
done
check "statusline roda" bash "${HOME}/.claude/statusline.sh" <<<'{"model":{"display_name":"Sonnet"}}'

# Git.
check "git com o delta de pager" test "$(git config --get core.pager)" = delta
if command -v lazygit >/dev/null; then
  check "delta e lazygit instalados" command -v delta
fi

exit "${fail}"
