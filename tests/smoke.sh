#!/usr/bin/env bash
# Confere o que o bootstrap deve deixar pronto. Roda no CI depois do ./bootstrap.sh.
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

for cmd in chezmoi metapac just cz; do
  if command -v "${cmd}" >/dev/null; then
    echo "ok: ${cmd}"
  else
    echo "FALTA: ${cmd} fora do PATH" >&2
    fail=1
  fi
done

link="${HOME}/.config/metapac"
if [ "$(readlink -f "${link}")" = "${repo}/packages" ]; then
  echo "ok: ${link} -> ${repo}/packages"
else
  echo "FALTA: ${link} não aponta para ${repo}/packages" >&2
  fail=1
fi

# O hook do rustup (grupo base) deixou a toolchain e o rust-analyzer.
if rustup which rustc >/dev/null 2>&1 && rustup which rust-analyzer >/dev/null 2>&1; then
  echo "ok: rustup com rustc e rust-analyzer"
else
  echo "FALTA: rustup sem toolchain ou sem rust-analyzer (hook do metapac)" >&2
  fail=1
fi

# Com o grupo terminal: a config do Ghostty é válida e a fonte está instalada.
if command -v ghostty >/dev/null; then
  if ghostty +validate-config --config-file="${HOME}/.config/ghostty/config"; then
    echo "ok: config do Ghostty"
  else
    echo "FALTA: config do Ghostty inválida" >&2
    fail=1
  fi
  # Sem pipe direto: com pipefail, o grep -q sai cedo e o fc-list morre de SIGPIPE, o que conta como falha.
  fonts="$(fc-list : family)"
  if grep -q "BlexMono Nerd Font" <<<"${fonts}"; then
    echo "ok: fonte BlexMono Nerd Font"
  else
    echo "FALTA: fonte BlexMono Nerd Font" >&2
    fail=1
  fi
fi

exit "${fail}"
