#!/usr/bin/env bash
# Statusline do Claude Code: modelo, contexto, cota do plano, custo e branch.
# Recebe o JSON da sessão no stdin (https://code.claude.com/docs/en/statusline).
# Também grava a cota em ~/.cache/devenv/claude-usage para o tmux mostrar na barra.
set -uo pipefail

input="$(cat)"
j() { jq -r "$1 // empty" <<<"${input}" 2>/dev/null; }

model="$(j '.model.display_name')"
ctx="$(j '.context_window.used_percentage')"
five="$(j '.rate_limits.five_hour.used_percentage')"
week="$(j '.rate_limits.seven_day.used_percentage')"
reset="$(j '.rate_limits.five_hour.resets_at')"
cost="$(j '.cost.total_cost_usd')"
dir="$(j '.workspace.current_dir')"
branch="$(git -C "${dir:-.}" branch --show-current 2>/dev/null || true)"

# Cores pela gravidade: verde < 50%, amarelo < 80%, vermelho acima.
color() {
  local v="${1%.*}"
  if [ -z "${v}" ]; then printf '\033[2m'; elif [ "${v}" -ge 80 ]; then printf '\033[31m'
  elif [ "${v}" -ge 50 ]; then printf '\033[33m'; else printf '\033[32m'; fi
}
dim=$'\033[2m'
off=$'\033[0m'

parts=("${model:-?}")
[ -n "${ctx}" ] && parts+=("$(color "${ctx}")ctx ${ctx%.*}%${off}")
if [ -n "${five}" ]; then
  left=""
  if [ -n "${reset}" ]; then
    mins=$(((reset - $(date +%s)) / 60))
    [ "${mins}" -gt 0 ] && left=" ${dim}($((mins / 60))h$((mins % 60))m)${off}"
  fi
  parts+=("$(color "${five}")5h ${five%.*}%${off}${left}")
fi
[ -n "${week}" ] && parts+=("$(color "${week}")7d ${week%.*}%${off}")
# Com a assinatura, o custo é o equivalente na API (referência, não cobrança).
[ -n "${cost}" ] && parts+=("${dim}\$$(printf '%.2f' "${cost}")${off}")
[ -n "${branch}" ] && parts+=($'\xee\x82\xa0'" ${branch}")

out=""
for p in "${parts[@]}"; do out+="${out:+ ${dim}│${off} }${p}"; done
printf '%s' "${out}"

# Cota para a barra do tmux (só se mudou, para não escrever à toa).
if [ -n "${five}" ]; then
  cache="${XDG_CACHE_HOME:-${HOME}/.cache}/devenv/claude-usage"
  line="5h ${five%.*}%${week:+ 7d ${week%.*}%}"
  if [ "$(cat "${cache}" 2>/dev/null)" != "${line}" ]; then
    mkdir -p "$(dirname "${cache}")" && printf '%s' "${line}" >"${cache}"
  fi
fi
