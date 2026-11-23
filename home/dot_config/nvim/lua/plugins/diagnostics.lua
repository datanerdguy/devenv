-- Erros e avisos: um sinal na margem para todos e, na linha do cursor, a mensagem numa caixa ao lado do código
-- (tiny-inline-diagnostic). Ctrl-w d abre o erro inteiro; ]d e [d andam entre eles.

vim.pack.add({ "https://github.com/rachartier/tiny-inline-diagnostic.nvim" }, { confirm = false })

require("tiny-inline-diagnostic").setup({
  preset = "modern",
  -- O fundo do editor é transparente (plugins/theme.lua); a caixa segue.
  transparent_bg = true,
  options = {
    -- Mostra de qual servidor veio a mensagem (ty, ruff...).
    show_source = { enabled = true },
    -- Mensagem longa quebra em várias linhas em vez de sumir na borda.
    multilines = { enabled = true },
  },
})

vim.diagnostic.config({
  -- O tiny-inline-diagnostic mostra o texto; o nativo ficaria duplicado.
  virtual_text = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})
