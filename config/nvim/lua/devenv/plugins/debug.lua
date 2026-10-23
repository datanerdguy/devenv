-- Debug (DAP). Tudo carrega só ao usar uma tecla de <leader>d.
local pack = require("devenv.pack")
local gh = function(x) return "https://github.com/" .. x end

local function dap(fn)
  return function() require("dap")[fn]() end
end

pack.add({
  { src = gh("igorlfs/nvim-dap-view"), keys = {} },
  { src = gh("mfussenegger/nvim-dap-python"), keys = {} },
  {
    src = gh("mfussenegger/nvim-dap"),
    deps = { "nvim-dap-view", "nvim-dap-python" },
    keys = {
      { "<leader>db", dap("toggle_breakpoint"), desc = "Breakpoint" },
      { "<leader>dc", dap("continue"), desc = "Iniciar / continuar" },
      { "<leader>di", dap("step_into"), desc = "Entrar" },
      { "<leader>do", dap("step_over"), desc = "Pular" },
      { "<leader>dO", dap("step_out"), desc = "Sair" },
      { "<leader>dr", dap("repl_toggle"), desc = "REPL" },
      { "<leader>dt", dap("terminate"), desc = "Encerrar" },
      { "<leader>du", function() require("dap-view").toggle() end, desc = "Painel do debug" },
    },
    config = function()
      require("dap-view").setup({ auto_toggle = true })
      -- Python: usa o ambiente do projeto via uv (debugpy precisa estar nas dependências de dev).
      require("dap-python").setup("uv")
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
    end,
  },
})
