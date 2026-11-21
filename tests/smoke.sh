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

# Com o grupo linguagens: o hook do rustup deixou a toolchain e o rust-analyzer.
if command -v rustup >/dev/null; then
  if rustup which rustc >/dev/null 2>&1 && rustup which rust-analyzer >/dev/null 2>&1; then
    echo "ok: rustup com rustc e rust-analyzer"
  else
    echo "FALTA: rustup sem toolchain ou sem rust-analyzer (hook do metapac)" >&2
    fail=1
  fi
fi

exit "${fail}"
