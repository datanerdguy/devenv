-- Confere cada servidor de plugins/lsp.lua: o nome existe no nvim-lspconfig e o
-- comando está instalado. Roda pelo tests/checar-nvim.sh. Servidores com o
-- comando montado por função ficam de fora: só abrindo um arquivo dá para ver.
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
