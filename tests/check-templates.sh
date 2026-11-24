#!/usr/bin/env bash
# Confere que cada ferramenta aceita o arquivo de templates/: chave errada ou
# config que não abre falha. Ferramenta que não está instalada fica de fora.
# Usado pelo just lint.
set -uo pipefail

templates="$(cd "$(dirname "$0")/../templates" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
failed=0

# check <o que> <comando...>: imprime FALTA e marca a falha se o comando falhar.
check() {
  local name="$1"
  shift
  if ! out="$("$@" 2>&1)"; then
    printf 'FALTA %s\n%s\n' "${name}" "${out}" >&2
    failed=1
  fi
}
have() { command -v "$1" >/dev/null; }

if have ruff; then
  check "python-data: pyproject.toml (ruff)" \
    ruff check --config "${templates}/python-data/pyproject.toml" --no-cache --quiet "${templates}/python-data"
  check "python: pyproject.toml (ruff)" \
    ruff check --config "${templates}/python/pyproject.toml" --no-cache --quiet "${templates}/python"
fi
if have golangci-lint; then
  check "go: .golangci.yml" golangci-lint config verify -c "${templates}/go/.golangci.yml"
fi
if have rustfmt; then
  # Opção desconhecida no rustfmt.toml só vira aviso; aviso conta como falha.
  check "rust: rustfmt.toml" sh -c "echo 'fn main() {}' | rustfmt --config-path '${templates}/rust/rustfmt.toml' 2>&1 >/dev/null | grep -q . && exit 1 || exit 0"
fi
if have cargo; then
  mkdir -p "${tmp}/rust/src" && echo 'fn main() {}' >"${tmp}/rust/src/main.rs"
  printf '[package]\nname = "x"\nversion = "0.1.0"\nedition = "2024"\n\n' >"${tmp}/rust/Cargo.toml"
  cat "${templates}/rust/lints.toml" >>"${tmp}/rust/Cargo.toml"
  check "rust: lints.toml no Cargo.toml" cargo metadata --no-deps --offline --format-version 1 --manifest-path "${tmp}/rust/Cargo.toml"
fi
if have prettier; then
  check "typescript: .prettierrc.json" sh -c "echo 'const a = 1;' | prettier --config '${templates}/typescript/.prettierrc.json' --stdin-filepath x.ts"
fi
check "typescript: tsconfig.json é JSON" jq -e .compilerOptions "${templates}/typescript/tsconfig.json"
if have stylua; then
  check "lua: .stylua.toml" sh -c "echo 'local a = 1' | stylua --config-path '${templates}/lua/.stylua.toml' -"
fi
if have clang-format; then
  check "c: .clang-format" clang-format --style="file:${templates}/c/.clang-format" --dump-config
fi
if have clang-tidy; then
  check "c: .clang-tidy" clang-tidy --config-file="${templates}/c/.clang-tidy" --verify-config
fi
if have mix; then
  check "elixir: .formatter.exs" sh -c "cd '${tmp}' && cp '${templates}/elixir/.formatter.exs' . && echo 'a = 1' | mix format -"
fi

exit "${failed}"
