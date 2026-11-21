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
fi

exit "${fail}"
