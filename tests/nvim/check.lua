-- Teste headless da config do Neovim:
--   nvim --headless -l tests/nvim/check.lua
-- Carrega todos os plugins, abre arquivos de várias linguagens e falha se algo der erro.
local errors = {}
-- Guarda os erros de vim.notify. Roda de novo depois do init, porque o snacks troca o vim.notify.
local wrapper
local function capture()
  if vim.notify == wrapper then return end
  local notify = vim.notify
  wrapper = function(msg, level, ...)
    if level and level >= vim.log.levels.ERROR then table.insert(errors, msg) end
    return notify(msg, level, ...)
  end
  vim.notify = wrapper
end
capture()

vim.opt.rtp:prepend(vim.fn.stdpath("config"))
local ok, err = pcall(dofile, vim.fn.stdpath("config") .. "/init.lua")
if not ok then table.insert(errors, "init.lua: " .. tostring(err)) end

if vim.v.errmsg ~= "" then table.insert(errors, "errmsg: " .. vim.v.errmsg) end
local pack = require("pcastr.pack")
-- Carrega um a um, capturando de novo antes de cada plugin (um deles pode trocar o vim.notify).
for _, name in ipairs(pack.order) do
  capture()
  pack.load(name)
end
-- Os quatro temas aplicam sem erro (o `theme` troca entre eles com o editor aberto).
local theme = require("pcastr.theme")
for id in pairs(theme.schemes) do
  capture()
  vim.g.colors_name = nil
  theme.apply(id)
  if not vim.g.colors_name then table.insert(errors, "tema " .. id .. ": colorscheme não carregou") end
end
vim.wait(200) -- deixa rodar o que os plugins agendaram (alguns só avisam erro assim)
vim.api.nvim_exec_autocmds("VimEnter", {})
vim.api.nvim_exec_autocmds("UIEnter", {})

for _, f in ipairs({ "a.py", "a.go", "a.rs", "a.lua", "a.nix", "a.md", "a.sh" }) do
  local okf, errf = pcall(vim.cmd.edit, vim.fn.tempname() .. f)
  if not okf then table.insert(errors, f .. ": " .. errf) end
end

local missing = {}
for name, p in pairs(pack.plugins) do
  if p.error then table.insert(errors, name .. ": " .. p.error) end
  if #vim.api.nvim_get_runtime_file("pack/*/opt/" .. name, false) == 0 then table.insert(missing, name) end
end
if #missing > 0 then table.insert(errors, "não instalados: " .. table.concat(missing, ", ")) end

local n = vim.tbl_count(pack.plugins)
if #errors > 0 then
  io.stderr:write(("FALHOU (%d plugins):\n  %s\n"):format(n, table.concat(errors, "\n  ")))
  os.exit(1)
end
io.stdout:write(("ok: %d plugins carregados sem erro\n"):format(n))
os.exit(0)
