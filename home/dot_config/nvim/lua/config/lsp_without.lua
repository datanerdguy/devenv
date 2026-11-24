-- Handlers de LSP que tiram os avisos repetidos de um servidor (quando outro
-- já dá o mesmo), venham eles quando o Neovim pede (pull) ou sozinhos (push).
-- Usado em after/lsp/ruff.lua e after/lsp/ty.lua.
return function(repeated)
  local function keep(list)
    return vim.tbl_filter(function(d) return not repeated(d) end, list or {})
  end
  return {
    ["textDocument/diagnostic"] = function(err, result, ctx)
      if result then result.items = keep(result.items) end
      return vim.lsp.diagnostic.on_diagnostic(err, result, ctx)
    end,
    ["textDocument/publishDiagnostics"] = function(err, result, ctx)
      result.diagnostics = keep(result.diagnostics)
      return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
    end,
  }
end
