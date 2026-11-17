-- Debug (DAP). Tudo carrega só ao usar uma tecla de <leader>d.
local lazy = require("pcastr.lazy")
local gh = function(x) return "https://github.com/" .. x end

local function dap(fn)
  return function() require("dap")[fn]() end
end

lazy.install({ gh("mfussenegger/nvim-dap"), gh("igorlfs/nvim-dap-view"), gh("mfussenegger/nvim-dap-python") })

lazy.keys(
  lazy.loader({ "nvim-dap", "nvim-dap-view", "nvim-dap-python" }, function()
    require("dap-view").setup({ auto_toggle = true })
    -- Python: usa o ambiente do projeto via uv (debugpy precisa estar nas dependências de dev).
    require("dap-python").setup("uv")
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
  end),
  {
    { "<leader>db", dap("toggle_breakpoint"), desc = "[Debug] Alternar breakpoint" },
    { "<leader>dc", dap("continue"), desc = "[Debug] Iniciar / continuar" },
    { "<leader>di", dap("step_into"), desc = "[Debug] Step into (entrar)" },
    { "<leader>do", dap("step_over"), desc = "[Debug] Step over (pular)" },
    { "<leader>dO", dap("step_out"), desc = "[Debug] Step out (sair)" },
    { "<leader>dr", dap("repl_toggle"), desc = "[Debug] Alternar REPL" },
    { "<leader>dt", dap("terminate"), desc = "[Debug] Encerrar sessão" },
    { "<leader>du", function() require("dap-view").toggle() end, desc = "[Debug] Alternar painel" },
  }
)
