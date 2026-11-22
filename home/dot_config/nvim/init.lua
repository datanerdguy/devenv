-- Neovim do devenv (docs/neovim.md). Só o que é nativo do Neovim 0.13, sem plugins.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.search")
require("config.keymaps")
