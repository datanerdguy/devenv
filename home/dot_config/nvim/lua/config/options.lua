-- Opções gerais.
local o = vim.o

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Tela. Números das linhas: a atual mostra o número dela; as outras, a distância até ela (para 5j, 3k...).
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
-- Linha vertical na coluna 80; ao digitar, o texto que passa dela quebra sozinho.
o.textwidth = 80
o.colorcolumn = "80"
-- O modo já aparece na cor do cursor (config/cursor.lua).
o.showmode = false
o.splitright = true
o.splitbelow = true

-- Edição. O .editorconfig do projeto vence a indentação daqui.
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.shiftround = true
o.smartindent = true
o.breakindent = true
o.virtualedit = "block"
-- y, d e p usam o clipboard do sistema.
o.clipboard = "unnamedplus"

-- Busca: sem maiúscula ignora maiúsculas; com uma, respeita.
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"
o.grepprg = "rg --vimgrep --hidden --glob '!.git'"

-- Nada de swap (.swp) nem backup (arquivo~): o git guarda o histórico.
o.swapfile = false
o.backup = false
o.writebackup = false

-- Menu fuzzy na linha de comando (: / ?), que aparece enquanto você digita (:help cmdline-autocompletion).
o.wildmode = "noselect:lastused,full"
o.wildoptions = "pum,fuzzy"
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", "?" },
  callback = function() vim.fn.wildtrigger() end,
})
-- Com o menu aberto, as setas saem dele e andam no histórico, como sem o menu.
local function history(key)
  return function() return vim.fn.wildmenumode() == 1 and "<C-e>" .. key or key end
end
vim.keymap.set("c", "<Up>", history("<Up>"), { expr = true })
vim.keymap.set("c", "<Down>", history("<Down>"), { expr = true })
