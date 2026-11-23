#!/usr/bin/env bash
# Depois do `metapac sync`: devolve às dependências o status de dependência.
# O metapac instala com `--asexplicit`, então as dependências viriam como explícitas e o `metapac clean`
# tentaria removê-las. Aqui vira dependência todo pacote de fora das listas que outro pacote exige.
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
