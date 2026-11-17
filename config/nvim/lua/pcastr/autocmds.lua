local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("pcastr", { clear = true })

local cursor_colors = {
  CursorNormal = "Cursor",
  CursorInsert = "DiagnosticOk",
  CursorVisual = "DiagnosticInfo",
  CursorReplace = "DiagnosticError",
}
local function set_cursor_colors()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  for group_name, from in pairs(cursor_colors) do
    local hl = vim.api.nvim_get_hl(0, { name = from, link = false })
    -- Cursor usa o fundo; sem ele (Dracula), a cor do texto.
    local color = from == "Cursor" and (hl.bg or normal.fg) or hl.fg
    if color then vim.api.nvim_set_hl(0, group_name, { bg = color, fg = normal.bg }) end
  end
end
au("ColorScheme", { group = group, callback = set_cursor_colors })

-- Destaca o texto copiado
au("TextYankPost", {
  group = group,
  callback = function() vim.hl.hl_op({ timeout = 150 }) end,
})

-- Volta para a última posição ao reabrir um arquivo
au("BufReadPost", {
  group = group,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[ev.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Recarrega arquivos alterados fora do editor (por exemplo, por um agente)
au({ "FocusGained", "TermClose", "TermLeave", "BufEnter" }, {
  group = group,
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

-- Iguala as janelas quando o terminal muda de tamanho
au("VimResized", { group = group, command = "tabdo wincmd =" })

-- Texto corrido: quebra de linha e corretor
au("FileType", {
  group = group,
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fecha janelas auxiliares com q
au("FileType", {
  group = group,
  pattern = { "help", "qf", "checkhealth", "man", "nvim-pack" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set(
      "n",
      "q",
      "<cmd>close<cr>",
      { buf = ev.buf, silent = true, desc = "[Janela] Fechar janela auxiliar" }
    )
  end,
})

-- Cria pastas que faltam ao salvar
au("BufWritePre", {
  group = group,
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then return end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h"), "p")
  end,
})
