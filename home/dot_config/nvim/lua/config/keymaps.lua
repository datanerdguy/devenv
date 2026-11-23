-- Atalhos do Neovim sem plugin (o <leader> é o Espaço). Os de cada plugin ficam
-- no arquivo dele, em lua/plugins/. Toda desc segue "[Categoria] Ação".
local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "[Geral] Sair do modo de inserção" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "[Geral] Salvar o arquivo" })

-- Salva tudo e reinicia: a config é relida e as janelas voltam como estavam.
map(
  "n",
  "<leader>R",
  "<cmd>silent! wall | restart<cr>",
  { desc = "[Geral] Salvar e reiniciar o Neovim" }
)
-- No restart, os argumentos (o `.` do `nvim .` abre o oil) abrem antes da
-- sessão e marcariam o arquivo restaurado como oil, sem cor: saem antes dela.
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
