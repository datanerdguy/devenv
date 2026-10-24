-- pcastr: config do Neovim (nightly 0.13, plugins pelo vim.pack nativo).
-- Ordem: opções -> teclas -> autocmds -> plugins -> LSP.
-- Quase tudo carrega sob demanda; veja docs/neovim.md e `:Pack`.

vim.loader.enable() -- cache de bytecode Lua: abre mais rápido

require("pcastr.options")
require("pcastr.keymaps")
require("pcastr.data")
require("pcastr.autocmds")
require("pcastr.plugins")
require("pcastr.lsp")
