-- Opções do editor. `:help '<opção>'` explica cada uma.
local o, g = vim.o, vim.g

g.mapleader = " "
g.maplocalleader = "\\"

-- Providers que não usamos: menos coisa para procurar ao abrir.
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
-- netrw: o explorer do snacks já abre diretórios (replace_netrw)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
-- Python só para o molten (notebooks); o Nix aponta o interpretador certo.
if vim.env.DEVENV_NVIM_PYTHON then g.python3_host_prog = vim.env.DEVENV_NVIM_PYTHON end

-- Interface
o.number = true
o.relativenumber = true
o.signcolumn = "yes" -- não pula o texto quando aparece um sinal
o.cursorline = true
o.termguicolors = true
o.showmode = false -- o modo aparece na statusline
o.laststatus = 3 -- uma statusline global
o.cmdheight = 1
o.pumheight = 12
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false
o.linebreak = true
o.list = true
o.listchars = "tab:» ,trail:·,nbsp:␣"
o.fillchars = "eob: ,fold: ,foldopen:▾,foldclose:▸,foldsep: "
o.winborder = "rounded" -- borda em todas as janelas flutuantes (0.11+)
o.splitright = true
o.splitbelow = true
o.splitkeep = "screen"

-- Edição
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.shiftround = true
o.smartindent = true
o.breakindent = true
o.virtualedit = "block"
o.clipboard = "unnamedplus" -- usa o clipboard do sistema (wl-clipboard no Wayland)
o.mouse = "a"
o.confirm = true -- pergunta em vez de falhar ao sair com mudanças
o.undofile = true
o.undolevels = 10000
o.swapfile = false
o.updatetime = 250
o.timeoutlen = 400

-- Busca
o.ignorecase = true
o.smartcase = true
o.inccommand = "split" -- prévia do :s/// numa janela
o.grepprg = "rg --vimgrep --hidden --glob '!.git'"
o.grepformat = "%f:%l:%c:%m"

-- Completion e folds
o.completeopt = "menu,menuone,noselect,popup"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""

o.spelllang = "pt_br,en"
-- Palavras aceitas pelo corretor (zg adiciona): fica no repo, versionado.
o.spellfile = vim.fn.stdpath("config") .. "/spell/tech.utf-8.add"
vim.opt.shortmess:append("WIcC")
