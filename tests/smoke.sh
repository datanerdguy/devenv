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

exit "${fail}"
