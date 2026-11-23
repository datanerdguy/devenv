-- Confere que existe o comando de cada servidor ligado em home/dot_config/nvim/lua/plugins/lsp.lua. O pacote vem
-- de packages/groups/linguagens.toml; se ele sair de lá e o servidor continuar na lista, isto falha.
-- Uso: nvim --headless -c "luafile tests/checar-lsp.lua" (com a config do Neovim carregada).
-- Alguns servidores montam o comando numa função (o nvim-lspconfig procura antes no node_modules do projeto);
-- esses só dá para conferir abrindo um arquivo, então ficam de fora.
local missing = {}
for _, name in ipairs(require("plugins.lsp").servers) do
  local cmd = vim.lsp.config[name].cmd
  if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 0 then
    table.insert(missing, name .. " (" .. cmd[1] .. ")")
  end
end
if #missing > 0 then
  io.stderr:write("Servidor sem o comando instalado: " .. table.concat(missing, ", ") .. "\n")
  vim.cmd.cquit(1)
end
vim.cmd.qall()
