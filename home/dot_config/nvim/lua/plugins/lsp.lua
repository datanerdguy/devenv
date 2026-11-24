-- LSP: os servidores vêm do metapac (packages/groups/languages.toml)
-- e a config de cada um vem do nvim-lspconfig (só a pasta lsp/ dele). Ajuste de
-- um servidor vai em after/lsp/<servidor>.lua, que vale por cima.

vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/b0o/SchemaStore.nvim",
}, { confirm = false })

-- Lua do Neovim: o lazydev ensina ao lua_ls a API do Neovim e a dos plugins que
-- o arquivo usa com require.
require("lazydev").setup({
  library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
})

-- O basedpyright fica instalado, mas desligado (o ty é o padrão do Python).
local servers = {
  "rust_analyzer",
  "gopls",
  "ty",
  "ruff",
  "vtsls",
  "elp",
  "expert",
  "lua_ls",
  "clangd",
  "jdtls",
  "asm_lsp",
  "html",
  "superhtml",
  "htmx",
  "cssls",
  "tailwindcss",
  "jsonls",
  "yamlls",
  "tombi",
  "marksman",
  "bashls",
  "fish_lsp",
  "dockerls",
  "just",
}
vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("devenv_lsp", {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    -- Editar a tag de abertura no HTML muda a de fechamento junto.
    if client:supports_method("textDocument/linkedEditingRange") then
      vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
    end

    -- Os atalhos nativos (grn, gra, K, ]d...) ficam; as listas abrem no
    -- fzf-lua, com prévia.
    local fzf = require("fzf-lua")
    local function map(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    local function toggle_hints()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
        { bufnr = ev.buf }
      )
    end
    map("gd", fzf.lsp_definitions, "[LSP] Definição")
    map("grr", fzf.lsp_references, "[LSP] Referências")
    map("gri", fzf.lsp_implementations, "[LSP] Implementação")
    map("grt", fzf.lsp_typedefs, "[LSP] Definição do tipo")
    map("gO", fzf.lsp_document_symbols, "[LSP] Símbolos do arquivo")
    map(
      "<leader>fs",
      fzf.lsp_live_workspace_symbols,
      "[Buscar] Símbolos do projeto"
    )
    map("<leader>lh", toggle_hints, "[LSP] Dicas inline: liga e desliga")
    map("<leader>lr", "<cmd>lsp restart<cr>", "[LSP] Reiniciar")
  end,
})

return { servers = servers }
