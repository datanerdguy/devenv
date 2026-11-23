-- Completar enquanto digita, pelo blink.cmp: LSP, caminhos, snippets e palavras do arquivo, com a documentação ao
-- lado. A busca fuzzy é em Rust (o binário pronto vem junto da versão marcada).

vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
}, { confirm = false })

require("blink.cmp").setup({
  -- Teclas do Vim: Ctrl-n/Ctrl-p andam, Ctrl-y aceita, Ctrl-e fecha, Ctrl-Space abre, Ctrl-k mostra a assinatura.
  keymap = { preset = "default" },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  -- A assinatura da função aparece enquanto você escreve os argumentos.
  signature = { enabled = true },
  -- A linha de comando (:) fica com o menu nativo (options.lua).
  cmdline = { enabled = false },
})
