#!/usr/bin/env bash
# Mede o tempo de abertura do Neovim (mediana de N execuções) e falha acima do limite.
#   tests/nvim/startup.sh [limite_ms] [execuções]
# O limite padrão é folgado para os runners do CI; na máquina local fica bem abaixo.
set -euo pipefail

budget="${1:-80}"
runs="${2:-7}"
nvim="${NVIM:-nvim}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

"$nvim" --headless +qa >/dev/null 2>&1 # aquece o cache do vim.loader

times=()
for i in $(seq "$runs"); do
  "$nvim" --headless --startuptime "$tmp/$i.log" +qa >/dev/null 2>&1
  times+=("$(awk '/NVIM STARTED/ { print $1 }' "$tmp/$i.log")")
done

median="$(printf '%s\n' "${times[@]}" | sort -n | awk '{ a[NR] = $1 } END { print a[int((NR + 1) / 2)] }')"
echo "abertura do neovim: mediana ${median}ms em ${runs} execuções (limite ${budget}ms)"

# Os 5 trechos mais lentos da última execução, para achar o culpado.
# Sem `head`: com pipefail, o `sort` levava SIGPIPE quando o head fechava o pipe e o teste falhava à toa.
grep -E "require|sourcing" "$tmp/$runs.log" | sort -k2 -n -r | awk 'NR <= 5 { printf "  %sms  %s\n", $2, $NF }'

awk -v m="$median" -v b="$budget" 'BEGIN { exit !(m <= b) }' || {
  echo "FALHOU: abertura acima de ${budget}ms" >&2
  exit 1
}
