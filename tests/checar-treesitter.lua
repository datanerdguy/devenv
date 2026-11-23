-- Confere cada linguagem de home/dot_config/nvim/lua/plugins/treesitter.lua: o parser precisa estar instalado. E num
-- arquivo Python o realce precisa ser o do treesitter, não o antigo, por regex.
-- Roda pelo tests/checar-nvim.sh, com a config do Neovim já carregada.
local missing = vim.tbl_filter(
  function(language) return not vim.treesitter.language.add(language) end,
  require("plugins.treesitter").languages
)
vim.cmd.edit(vim.fn.tempname() .. ".py")
local problems = {}
if #missing > 0 then table.insert(problems, "falta o parser de " .. table.concat(missing, ", ")) end
if not vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
  table.insert(problems, "o realce do treesitter não ligou num arquivo .py")
end
if #problems > 0 then
  io.stderr:write("Treesitter com problema: " .. table.concat(problems, "; ") .. "\n")
  vim.cmd.cquit(1)
end
vim.cmd.qall()
