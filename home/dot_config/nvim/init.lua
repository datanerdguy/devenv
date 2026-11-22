-- Neovim do devenv (docs/neovim.md). O que é nativo do Neovim 0.13 primeiro; plugin só
-- quando o nativo não cobre (os temas, em theme.lua).

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.search")
require("config.keymaps")
require("config.navigation")
require("config.theme")
