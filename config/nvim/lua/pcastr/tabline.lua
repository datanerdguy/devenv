-- Abas com ícone, pasta e nome do arquivo da janela ativa de cada aba.
local M = {}

local function label(buf)
  local name = vim.api.nvim_buf_get_name(buf):gsub("^oil://", ""):gsub("/$", "")
  local kind = name == "" and "default" or vim.fn.isdirectory(name) == 1 and "directory" or "file"
  local icon, hl = MiniIcons.get(kind, name == "" and "file" or name)
  if name == "" then return icon, "[Sem nome]", hl end
  local dir = vim.fs.basename(vim.fs.dirname(name))
  return icon, vim.fs.joinpath(dir, vim.fs.basename(name)), hl
end

function M.render()
  local parts = {}
  local current = vim.api.nvim_get_current_tabpage()
  for nr, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local icon, text, icon_hl = label(vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab)))
    local hl = tab == current and "%#TabLineSel#" or "%#TabLine#"
    local colored_icon = icon_hl and ("%#" .. icon_hl .. "#" .. icon .. hl) or icon
    parts[#parts + 1] = ("%%%dT%s %s %s "):format(nr, hl, colored_icon, (text:gsub("%%", "%%%%")))
  end
  return table.concat(parts) .. "%#TabLineFill#%T"
end

return M
