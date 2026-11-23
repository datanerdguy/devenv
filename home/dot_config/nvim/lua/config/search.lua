-- Buscar arquivos, pastas e texto pelo fzf-lua: o mesmo fzf do shell, com prévia. Atalhos em keymaps.lua.

vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-web-devicons",
}, { confirm = false })

local fzf = require("fzf-lua")
fzf.setup({
  -- As cores vêm do tema do Neovim.
  fzf_colors = true,
  -- O menu de opções do Neovim (vim.ui.select) também abre no fzf.
  ui_select = {},
  files = { hidden = true },
  grep = { hidden = true },
})

-- Pastas do projeto (fd), e a escolhida abre no explorer (oil).
local function folders()
  fzf.fzf_exec("fd --type directory --hidden --exclude .git", {
    prompt = "pasta ❯ ",
    actions = { enter = function(selected) require("oil").open(selected[1]) end },
  })
end

-- Pastas que o zoxide conhece (as que você mais usa, de qualquer projeto), abertas no explorer.
local function zoxide()
  fzf.zoxide({ actions = { enter = function(selected) require("oil").open(selected[1]:match("[^\t]+$")) end } })
end

return { folders = folders, zoxide = zoxide }
