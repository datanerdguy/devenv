-- CSV e TSV em colunas alinhadas (csvview.nvim), ligado ao abrir o arquivo.
-- Tab e Shift-Tab andam entre os campos; if e af selecionam um campo.

vim.pack.add({ "https://github.com/hat0uma/csvview.nvim" }, { confirm = false })

require("csvview").setup({
  view = { display_mode = "border" },
  keymaps = {
    textobject_field_inner = { "if", mode = { "o", "x" } },
    textobject_field_outer = { "af", mode = { "o", "x" } },
    jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
    jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "csv", "tsv" },
  callback = function() vim.cmd.CsvViewEnable() end,
})
