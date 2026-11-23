-- Confere cada servidor ligado em home/dot_config/nvim/lua/plugins/lsp.lua: o
-- nome precisa existir no nvim-lspconfig e o comando precisa estar instalado (o
-- pacote vem de packages/groups/linguagens.toml). Roda pelo
-- tests/checar-nvim.sh, com a config do Neovim já carregada. Alguns servidores
-- montam o comando numa função (o nvim-lspconfig procura antes no node_modules
-- do projeto); o comando desses só dá para conferir abrindo um arquivo, então
-- fica de fora.
local problems = {}
for _, name in ipairs(require("plugins.lsp").servers) do
  local config = vim.lsp.config[name]
  local cmd = config and config.cmd
  if not config then
    table.insert(problems, name .. " (o nvim-lspconfig não tem esse nome)")
  elseif type(cmd) == "table" and vim.fn.executable(cmd[1]) == 0 then
    table.insert(problems, name .. " (falta o comando " .. cmd[1] .. ")")
  end
end
if #problems > 0 then
  io.stderr:write(
    "Servidor LSP com problema: " .. table.concat(problems, ", ") .. "\n"
  )
  vim.cmd.cquit(1)
end
vim.cmd.qall()
