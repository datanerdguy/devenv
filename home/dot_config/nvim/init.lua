-- Neovim do devenv (docs/neovim.md). O que é nativo do Neovim 0.13 primeiro; plugin só
-- quando o nativo não cobre: temas, busca (fzf-lua) e explorer (oil). docs/neovim.md.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.theme")
require("config.search")
require("config.explorer")
require("config.keymaps")
require("config.navigation")
