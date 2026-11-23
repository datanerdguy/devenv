-- Claude: o claudecode.nvim fala com o Claude Code pelo mesmo protocolo da extensão do VS Code. O Claude roda num
-- painel do tmux, fora do Neovim; nele, /ide conecta a este Neovim. Com isso o Claude vê o arquivo aberto e a
-- seleção, e a mudança que ele propõe abre aqui como diff (:w aceita, :q recusa).

vim.pack.add({ "https://github.com/coder/claudecode.nvim" }, { confirm = false })

-- O tipo do terminal pede todos os campos; o |{} deixa passar só um, e os outros ficam no padrão do plugin.
---@type ClaudeCodeTerminalConfig|{}
local terminal = { provider = "none" }
-- Só avisos e erros: o "integration stopped" de cada saída não precisa aparecer.
require("claudecode").setup({ terminal = terminal, log_level = "warn" })

-- Depois de mandar um trecho, o foco vai para o painel do Claude (o último painel usado no tmux).
vim.api.nvim_create_autocmd("User", {
  pattern = "ClaudeCodeSendComplete",
  callback = function()
    if vim.env.TMUX then vim.system({ "tmux", "select-pane", "-t", "{last}" }) end
  end,
})

local map = vim.keymap.set
map("x", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "[Claude] Mandar a seleção" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "[Claude] Mandar o arquivo" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "[Claude] Aceitar a mudança" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "[Claude] Recusar a mudança" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function(ev)
    map("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = ev.buf, desc = "[Claude] Mandar o arquivo" })
  end,
})
