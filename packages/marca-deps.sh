#!/usr/bin/env bash
# Depois do `metapac sync`: devolve às dependências o status de dependência.
#
# O metapac instala com `paru --sync --asexplicit`, e o pacman marca como explícito tudo o que entra na
# transação, inclusive as dependências (ex.: python-textual, do posting). Assim elas aparecem no
# `metapac unmanaged`, e o `metapac clean` tentaria remover. Este script marca como dependência todo pacote
# fora das listas que algum outro pacote exige. O que ninguém exige (ex.: o stack que sobrou de um build do
# AUR) continua explícito e aparece no `just clean`.
set -euo pipefail

mapfile -t unmanaged < <(
  metapac unmanaged 2>/dev/null | python3 -c '
import sys, tomllib
for p in tomllib.loads(sys.stdin.read()).get("arch", {}).get("packages", []):
    print(p if isinstance(p, str) else p["name"])
'
)

deps=()
for pkg in "${unmanaged[@]}"; do
  # Sem pipe direto para o grep -q: com pipefail, o pacman morreria de SIGPIPE e contaria como falha.
  info="$(LC_ALL=C pacman -Qi "${pkg}")"
  if ! grep -q '^Required By *: None' <<<"${info}"; then
    deps+=("${pkg}")
  fi
done

if [ "${#deps[@]}" -eq 0 ]; then
  echo "Nenhuma dependência marcada como explícita."
  exit 0
fi
echo "Marcando ${#deps[@]} pacotes como dependência."
sudo pacman -D --asdeps "${deps[@]}" >/dev/null
