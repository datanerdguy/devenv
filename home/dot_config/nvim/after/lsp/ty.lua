-- A variável sem uso fica com o ruff (F841), que traz a correção: sai a dica
-- igual do ty, a de severidade Hint com a marca "unnecessary".
local protocol = vim.lsp.protocol

return {
  handlers = require("config.lsp_without")(
    function(d)
      return d.severity == protocol.DiagnosticSeverity.Hint
        and vim.list_contains(d.tags or {}, protocol.DiagnosticTag.Unnecessary)
    end
  ),
}
