-- Atalhos com o <leader> (Espaço). Toda desc segue "[Categoria] Ação".
local map = vim.keymap.set
local fzf = require("fzf-lua")
local search = require("config.search")

map("n", "<leader>ff", fzf.files, { desc = "[Buscar] Arquivos" })
map("n", "<leader>fd", search.folders, { desc = "[Buscar] Pastas do projeto" })
map("n", "<leader>fz", search.zoxide, { desc = "[Buscar] Pastas do zoxide" })
map("n", "<leader>fg", fzf.live_grep, { desc = "[Buscar] Texto no projeto" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "[Buscar] Palavra do cursor" })
map("n", "<leader>fb", fzf.buffers, { desc = "[Buscar] Arquivos abertos" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "[Buscar] Recentes" })
map("n", "<leader>fh", fzf.helptags, { desc = "[Buscar] Ajuda do Neovim" })
map("n", "<leader>fk", fzf.keymaps, { desc = "[Buscar] Atalhos" })
map("n", "<leader>f.", fzf.resume, { desc = "[Buscar] Voltar à última busca" })

map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
map("n", "-", "<cmd>Oil<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
map("n", "<leader>E", function() require("oil").open(vim.fn.getcwd()) end, { desc = "[Explorer] Raiz do projeto" })

-- Salva tudo e reinicia: a config é lida de novo, e os arquivos e janelas voltam como estavam.
map("n", "<leader>R", "<cmd>silent! wall | restart<cr>", { desc = "[Geral] Salvar e reiniciar o Neovim" })
