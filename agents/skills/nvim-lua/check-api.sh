#!/usr/bin/env bash
# Procura APIs do Neovim removidas ou deprecadas (0.12/0.13-dev) no código Lua.
#   check-api.sh [pasta]   (padrão: config/nvim e tests/nvim)
# Sai com 1 se achar algo. Fonte das regras: REFERENCIA.md, ao lado (deprecated.txt e news do Neovim).
set -euo pipefail

paths=("$@")
[ ${#paths[@]} -gt 0 ] || paths=(config/nvim tests/nvim)

# gravidade @ regex (rg) @ o que usar
rules=(
  'removida@vim\.tbl_islist\b@vim.islist'
  'removida@vim\.tbl_add_reverse_lookup\b@tabela inversa à mão'
  'removida@vim\.lsp\.get_active_clients\b@vim.lsp.get_clients({ bufnr = ... })'
  'removida@vim\.lsp\.buf_get_clients\b@vim.lsp.get_clients({ bufnr = ... })'
  'removida@vim\.lsp\.with\b@winborder e opções na chamada'
  'removida@vim\.lsp\.util\.jump_to_location\b@vim.lsp.util.show_document'
  'removida@vim\.lsp\.buf\.execute_command\b@client:exec_cmd'
  'removida@vim\.diagnostic\.(disable|is_disabled)\b@vim.diagnostic.enable(false) / is_enabled()'
  'removida@vim\.pretty_print\b@vim.print'
  'removida@BufModifiedSet@OptionSet com pattern "modified"'
  'deprecada@vim\.tbl_flatten\b@vim.iter(t):flatten():totable()'
  'deprecada@vim\.diagnostic\.goto_(next|prev)\b@vim.diagnostic.jump({ count = 1 })'
  'deprecada@vim\.lsp\.start_client\b@vim.lsp.start'
  'deprecada@vim\.F\.@vim.nonnil / vim.npcall'
  'deprecada@vim\.hl\.on_yank\b@vim.hl.hl_op'
  'deprecada@vim\.region\b@vim.fn.getregionpos'
  'deprecada@vim\.loop\b@vim.uv'
  'deprecada@vim\.highlight\b@vim.hl'
  'deprecada@nvim_(buf|win)_[gs]et_option\b@vim.bo[buf] / vim.wo[win] / nvim_get_option_value'
  'deprecada@\btermopen\(@vim.fn.jobstart(cmd, { term = true })'
  'deprecada@\bclient\.request\(@client:request(...)'
  'deprecada@\bbuffer\s*=@buf = (keymap e autocmd, 0.13)'
)

found=0
for rule in "${rules[@]}"; do
  IFS='@' read -r severity pattern fix <<<"$rule"
  # rg: 0 achou, 1 não achou, 2 erro (regex ou pasta inválida).
  code=0
  hits="$(rg --no-heading -n --type lua -e "$pattern" "${paths[@]}")" || code=$?
  [ "$code" -le 1 ] || { echo "erro do rg na regra: $pattern" >&2; exit 2; }
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    echo "${severity}: ${hit}  -> use ${fix}"
    found=1
  done <<<"$hits"
done

if [ "$found" = 1 ]; then
  echo "FALHOU: APIs removidas ou deprecadas no Lua do Neovim" >&2
  exit 1
fi
echo "ok: nenhuma API removida ou deprecada"
