-- O lockfile (nvim-pack-lock.json) fixa o commit de cada um e fica no git.
require("pcastr.theme") -- primeiro, para a tela já abrir com as cores do tema
require("pcastr.plugins.ui")
require("pcastr.plugins.editor")
require("pcastr.plugins.coding")
require("pcastr.plugins.ai")
require("pcastr.plugins.notebooks")
require("pcastr.plugins.notes")
require("pcastr.plugins.debug")

vim.keymap.set("n", "<leader>pu", "<cmd>packupdate<cr>", { desc = "[Plugins] Atualizar (revisa antes; :w aplica)" })
vim.keymap.set(
  "n",
  "<leader>pl",
  "<cmd>packupdate ++offline ++lockfile<cr>",
  { desc = "[Plugins] Voltar às versões do lockfile" }
)
