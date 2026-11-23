-- Atalhos do Neovim sem plugin (o <leader> é o Espaço). Os de cada plugin ficam no arquivo dele, em lua/plugins/.
-- Toda desc segue "[Categoria] Ação".
local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "[Geral] Sair do modo de inserção" })

-- Salva tudo e reinicia: a config é lida de novo, e os arquivos e janelas voltam como estavam.
map("n", "<leader>R", "<cmd>silent! wall | restart<cr>", { desc = "[Geral] Salvar e reiniciar o Neovim" })
-- No restart, o Neovim abre de novo os argumentos (o `.` do `nvim .` abre o oil) e depois restaura a sessão. O oil
-- termina de carregar depois e marcaria o arquivo restaurado como oil, sem cor. A sessão já traz as janelas: o que
-- os argumentos abriram sai antes dela.
if vim.v.startreason == "restart" then
  vim.api.nvim_create_autocmd("SessionLoadPre", {
    once = true,
    callback = function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
end
