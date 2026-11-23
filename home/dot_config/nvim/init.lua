-- Neovim do devenv (docs/neovim.md). O que é nativo do Neovim 0.13 primeiro; plugin só
-- quando o nativo não cobre: temas, busca, explorer, LSP, formatar e completar. docs/neovim.md.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.cursor")
require("config.theme")
require("config.search")
require("config.explorer")
require("config.lsp")
require("config.diagnostics")
require("config.format")
require("config.completion")
require("config.keymaps")
require("config.navigation")
