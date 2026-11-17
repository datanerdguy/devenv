-- IA no editor: claudecode.nvim, a integração de IDE do Claude Code (diffs revisados aqui no Neovim).
-- Carrega na primeira tecla de <leader>a ou no primeiro :ClaudeCode*.
local lazy = require("pcastr.lazy")

lazy.install({ "https://github.com/coder/claudecode.nvim" })

local load = lazy.loader(
  { "claudecode.nvim" },
  function()
    require("claudecode").setup({
      terminal = { split_side = "right", split_width_percentage = 0.4, provider = "snacks" },
      diff_opts = { layout = "vertical", open_in_new_tab = false },
    })
  end
)

lazy.cmds(load, {
  "ClaudeCode",
  "ClaudeCodeFocus",
  "ClaudeCodeSend",
  "ClaudeCodeAdd",
  "ClaudeCodeDiffAccept",
  "ClaudeCodeDiffDeny",
  "ClaudeCodeSelectModel",
})
lazy.keys(load, {
  { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "[Agente/Claude Code] Abrir/fechar" },
  { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "[Agente/Claude Code] Adicionar arquivo ao contexto" },
  { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "[Agente/Claude Code] Aceitar diff" },
  { "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "[Agente/Claude Code] Recusar diff" },
  { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "[Agente/Claude Code] Escolher modelo" },
  { "<leader>ae", "<cmd>ClaudeCodeSend<cr>", desc = "[Agente/Claude Code] Enviar seleção", mode = "x" },
})
