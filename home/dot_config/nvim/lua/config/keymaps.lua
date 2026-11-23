-- Atalhos do Neovim sem plugin (o <leader> é o Espaço). Os de cada plugin ficam no arquivo dele, em lua/plugins/.
-- Toda desc segue "[Categoria] Ação".
local map = vim.keymap.set

-- jk sai do modo de inserção, como o Esc.
map("i", "jk", "<Esc>", { desc = "[Geral] Sair do modo de inserção" })

-- Salva tudo e reinicia: a config é lida de novo, e os arquivos e janelas voltam como estavam.
map("n", "<leader>R", "<cmd>silent! wall | restart<cr>", { desc = "[Geral] Salvar e reiniciar o Neovim" })
