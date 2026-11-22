-- Atalhos com o <leader> (Espaço). Toda desc segue "[Categoria] Ação".
local map = vim.keymap.set

map("n", "<leader>ff", ":find ", { desc = "[Buscar] Arquivos" })
map("n", "<leader>fg", ":silent grep ", { desc = "[Buscar] Texto no projeto" })
map("n", "<leader>fb", ":b ", { desc = "[Buscar] Arquivos abertos" })
map("n", "<leader>fr", ":Recentes ", { desc = "[Buscar] Recentes" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
-- Salva tudo e reinicia: a config é lida de novo, e os arquivos e janelas voltam como estavam.
map("n", "<leader>R", "<cmd>silent! wall | restart<cr>", { desc = "[Geral] Salvar e reiniciar o Neovim" })
