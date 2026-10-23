#!/usr/bin/env bash
# Gera projetos com o `new` e roda o `just ci` de cada um (o mesmo CI que o projeto gerado roda).
# uso: tests/templates.sh [linguagem:tipo[:opção] ...]   ex.: tests/templates.sh python:api python:api:postgres
# Sem argumentos, testa todos. Com DEVENV_TEST_DOCKER=1, também gera a imagem Docker quando o projeto tem uma.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
cases=("$@")
if [ ${#cases[@]} -eq 0 ]; then
  cases=(
    python:lib python:api python:api:postgres python:llm python:data python:ml
    python:fastapi-htmx python:django python:streamlit
    go:cli go:service go:htmx rust:bin rust:lib elixir:phoenix
  )
fi

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
new="$(nix build --no-link --print-out-paths "${repo}#new")/bin/new"

export GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-devenv-ci}" GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-ci@example.com}"
export GIT_COMMITTER_NAME="${GIT_AUTHOR_NAME}" GIT_COMMITTER_EMAIL="${GIT_AUTHOR_EMAIL}"

for case in "${cases[@]}"; do
  IFS=: read -r lang kind option <<<"${case}"
  name="t-${lang}-${kind}${option:+-${option}}"
  echo "::group::${case}"
  extra=()
  [ -n "${option}" ] && extra=(--data "${option}=true")
  (cd "${work}" && DEVENV_REPO="${repo}" "${new}" "${lang}" "${name}" "${kind}" --defaults "${extra[@]}")
  (cd "${work}/${name}" && nix develop --command just ci)
  if [ "${DEVENV_TEST_DOCKER:-0}" = 1 ] && [ -f "${work}/${name}/Dockerfile" ]; then
    docker build --quiet --tag "${name}" "${work}/${name}"
  fi
  echo "::endgroup::"
  echo "ok    ${case}"
done
