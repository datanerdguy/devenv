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
-- Teclas e comandos sob demanda existem antes de carregar (pcastr.lazy).
local leader = vim.g.mapleader
for _, lhs in ipairs({ "ac", "cf", "db", "ni", "zn", "pu" }) do
  if not vim.fn.maparg(leader .. lhs, "n", false, true).desc then
    table.insert(errors, "tecla sem desc: <leader>" .. lhs)
  end
end
for _, cmd in ipairs({ "ClaudeCode", "Mason", "Obsidian", "ConformInfo" }) do
  if vim.fn.exists(":" .. cmd) ~= 2 then table.insert(errors, "comando faltando: " .. cmd) end
end
-- Carrega um a um, capturando de novo antes de cada loader (um plugin pode trocar o vim.notify).
for _, load in ipairs(require("pcastr.lazy").loaders) do
  capture()
  local okl, errl = pcall(load)
  if not okl then table.insert(errors, "loader: " .. tostring(errl)) end
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

local plugins = vim.pack.get(nil, { info = false })
local missing = vim.tbl_filter(function(p) return vim.fn.isdirectory(p.path) == 0 end, plugins)
if #missing > 0 then
  local names = vim.tbl_map(function(p) return p.spec.name end, missing)
  table.insert(errors, "não instalados: " .. table.concat(names, ", "))
end

local n = #plugins
if #errors > 0 then
  io.stderr:write(("FALHOU (%d plugins):\n  %s\n"):format(n, table.concat(errors, "\n  ")))
  os.exit(1)
end
io.stdout:write(("ok: %d plugins carregados sem erro\n"):format(n))
os.exit(0)
