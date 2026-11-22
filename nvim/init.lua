-- Neovim do devenv (docs/neovim.md). Por enquanto: navegar pelos arquivos e reiniciar aplicando a config.
-- Plugins pelo vim.pack nativo; as versões ficam em nvim-pack-lock.json, no git.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- snacks.nvim: busca de arquivos e de texto (picker) e árvore de pastas (explorer).
vim.pack.add({ { src = "https://github.com/folke/snacks.nvim", version = vim.version.range("*") } }, { confirm = false })
require("snacks").setup({
  -- `nvim .` ou `:e pasta/` abrem a árvore no lugar do netrw.
  explorer = { replace_netrw = true },
  -- As buscas mostram arquivos ocultos (.github, .config...); os ignorados pelo git ficam de fora.
  picker = { hidden = true },
})

local map = vim.keymap.set
map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "[Buscar] Arquivos (recentes e do projeto)" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "[Buscar] Arquivos" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "[Buscar] Texto no projeto" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "[Buscar] Arquivos abertos" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "[Buscar] Recentes" })
map("n", "<leader>e", function() Snacks.explorer() end, { desc = "[Explorer] Abrir/fechar a árvore" })

-- Salva tudo e reinicia: a config é lida de novo, e os arquivos e janelas voltam como estavam (:restart).
map("n", "<leader>R", "<cmd>silent! wall | restart<cr>", { desc = "[Geral] Salvar e reiniciar o Neovim" })
