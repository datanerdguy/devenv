-- Formatar ao salvar, pelo conform. Cada linguagem usa o formatador da tabela
-- do ADR 0010 e, sem um, o do LSP. O conform prefere o formatador do projeto
-- (node_modules/.bin, por exemplo) ao da máquina.

vim.pack.add(
  { "https://github.com/stevearc/conform.nvim" },
  { confirm = false }
)

local prettier = { "prettier" }

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    go = { "gofumpt" },
    rust = { "rustfmt" },
    elixir = { "mix" },
    heex = { "mix" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    java = { "google-java-format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    fish = { "fish_indent" },
    toml = { "tombi" },
    just = { "just" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    html = prettier,
    css = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    markdown = prettier,
  },
  formatters = {
    -- O prettier só roda em projeto que tem config dele (.prettierrc e afins).
    -- Sem isso, ele reescreveria docs e configs no estilo padrão dele, que não
    -- é o de todo projeto (o deste repo, por exemplo).
    prettier = { require_cwd = true },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = { timeout_ms = 1000 },
})

-- gq também formata pelo conform.
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set(
  { "n", "x" },
  "<leader>lf",
  function() require("conform").format() end,
  { desc = "[LSP] Formatar" }
)
