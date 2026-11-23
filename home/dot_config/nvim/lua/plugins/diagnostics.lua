-- Erros e avisos: um emoji na margem para cada um e, na linha do cursor, a
-- mensagem numa caixa ao lado do código (tiny-inline-diagnostic). Ctrl-w d
-- abre o erro inteiro; ]d e [d andam entre eles.

vim.pack.add(
  { "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
  { confirm = false }
)

local severity = vim.diagnostic.severity

-- Os emojis valem para a margem, a caixa ao lado do código, a janela do erro
-- (Ctrl-w d) e a contagem na barra de status.
local icons = {
  [severity.ERROR] = "⛔",
  [severity.WARN] = "⚠️",
  [severity.INFO] = "ℹ️",
  [severity.HINT] = "💡",
}
local colors = {
  [severity.ERROR] = "DiagnosticSignError",
  [severity.WARN] = "DiagnosticSignWarn",
  [severity.INFO] = "DiagnosticSignInfo",
  [severity.HINT] = "DiagnosticSignHint",
}

vim.diagnostic.config({
  -- O tiny-inline-diagnostic mostra o texto; o nativo ficaria duplicado.
  virtual_text = false,
  -- O erro vem antes do aviso, na margem e nas listas.
  severity_sort = true,
  signs = {
    text = icons,
    -- O número da linha ganha a cor do erro ou do aviso.
    numhl = colors,
  },
  -- Na barra de status: ⛔ 2 ⚠️ 1, com a cor de cada um.
  status = {
    format = function(counts)
      local parts = {}
      for level = severity.ERROR, severity.HINT do
        if counts[level] then
          local part = "%#" .. colors[level] .. "#" .. icons[level] .. " "
          table.insert(parts, part .. counts[level])
        end
      end
      return table.concat(parts, " ")
    end,
  },
  float = {
    border = "rounded",
    source = true,
    prefix = function(diagnostic) return icons[diagnostic.severity] .. " ", "" end,
  },
})

require("tiny-inline-diagnostic").setup({
  preset = "modern",
  -- O fundo do editor é transparente (plugins/theme.lua); a caixa segue.
  transparent_bg = true,
  options = {
    show_source = { enabled = true },
    multilines = { enabled = true },
    use_icons_from_diagnostic = true,
  },
})
