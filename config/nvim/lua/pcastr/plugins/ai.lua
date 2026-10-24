-- IA no editor.
--   sidekick.nvim: terminal com qualquer CLI de agente (Claude, Codex, Gemini, opencode...),
--                  mandando arquivo, seleção e diagnósticos. Sessões ficam no tmux.
--   claudecode.nvim: integração de IDE do Claude Code (diffs revisados aqui no Neovim).
local pack = require("pcastr.pack")
local gh = function(x) return "https://github.com/" .. x end

pack.add({
  {
    src = gh("folke/sidekick.nvim"),
    keys = {
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Agente: abrir/fechar",
        mode = { "n", "x" },
      },
      { "<leader>as", function() require("sidekick.cli").select() end, desc = "Agente: escolher CLI" },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        desc = "Agente: mandar isto",
        mode = { "n", "x" },
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Agente: mandar arquivo",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        desc = "Agente: mandar seleção",
        mode = "x",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        desc = "Agente: prompts prontos",
        mode = { "n", "x" },
      },
      { "<leader>ad", function() require("sidekick.cli").close() end, desc = "Agente: encerrar sessão" },
      {
        "<C-.>",
        function() require("sidekick.cli").focus() end,
        desc = "Agente: focar",
        mode = { "n", "t", "i", "x" },
      },
    },
    config = function()
      require("sidekick").setup({
        nes = { enabled = false }, -- sugestões do Copilot: desligado (sem assinatura)
        cli = {
          mux = { backend = "tmux", enabled = true }, -- sessão continua viva fora do Neovim
          win = { layout = "right", split = { width = 0.4 } },
        },
      })
    end,
  },

  {
    src = gh("coder/claudecode.nvim"),
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend",
      "ClaudeCodeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code: abrir/fechar" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude Code: adicionar arquivo" },
      { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Code: aceitar diff" },
      { "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude Code: recusar diff" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude Code: escolher modelo" },
    },
    config = function()
      require("claudecode").setup({
        terminal = { split_side = "right", split_width_percentage = 0.4, provider = "snacks" },
        diff_opts = { layout = "vertical", open_in_new_tab = false },
      })
    end,
  },
})

-- Mandar a seleção visual para o Claude Code
vim.keymap.set("x", "<leader>ae", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude Code: mandar seleção" })
