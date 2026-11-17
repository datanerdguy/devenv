-- Código: completion, formatação, lint, diagnósticos inline e instalador de LSP.
local lazy = require("pcastr.lazy")
local gh = function(x) return "https://github.com/" .. x end

-- nvim-lspconfig: configurações prontas de cada servidor (lsp/*.lua). Só dados: o lua/pcastr/lsp.lua faz o
-- packadd dele no primeiro arquivo, antes do vim.lsp.enable.
lazy.install({
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason.nvim"),
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") }, -- versão com binário pronto do fuzzy em Rust
  gh("rachartier/tiny-inline-diagnostic.nvim"),
  gh("stevearc/conform.nvim"),
  gh("mfussenegger/nvim-lint"),
})

local group = vim.api.nvim_create_augroup("pcastr.coding", { clear = true })

-- Instalador fácil de LSPs, formatadores e linters (:Mason). O que o Nix já instala tem prioridade.
lazy.cmds(
  lazy.loader({ "mason.nvim" }, function()
    require("mason").setup({ PATH = "skip" }) -- o PATH já é ajustado em lsp.lua
  end),
  { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" }
)

-- Completion só no primeiro insert ou na linha de comando. As capacidades que ele anuncia ao LSP
-- ficam em lsp.lua, para os servidores que sobem antes dele.
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  group = group,
  once = true,
  callback = lazy.loader({ "blink.cmp" }, function()
    require("blink.cmp").setup({
      -- Tab aceita (ou pula para o próximo campo do snippet); C-n/C-p escolhem; C-Space abre; C-e fecha.
      keymap = { preset = "super-tab" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { draw = { treesitter = { "lsp" } } },
        list = { selection = { preselect = true, auto_insert = false } }, -- o primeiro já vem marcado para o Tab
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      cmdline = { enabled = true, completion = { menu = { auto_show = true } } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    })
  end),
})

-- Diagnóstico inline bonito. O virtual_text do LSP fica desligado para não sobrepor.
vim.api.nvim_create_autocmd({ "LspAttach", "DiagnosticChanged" }, {
  group = group,
  once = true,
  callback = lazy.loader({ "tiny-inline-diagnostic.nvim" }, function()
    vim.diagnostic.config({ virtual_text = false })
    require("tiny-inline-diagnostic").setup({
      preset = "modern",
      options = {
        show_source = { enabled = true, if_many = true },
        multilines = { enabled = true, always_show = false },
        throttle = 50,
      },
    })
  end),
})

local load_conform = lazy.loader({ "conform.nvim" }, function()
  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_organize_imports", "ruff_format" },
      go = { "goimports", "gofumpt" },
      rust = { "rustfmt" },
      nix = { "nixfmt" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      fish = { "fish_indent" },
      toml = { "taplo" },
      elixir = { "mix" },
    },
    default_format_opts = { lsp_format = "fallback" },
  })
  vim.keymap.set("n", "<leader>uf", function()
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify("Formatar ao salvar: " .. (vim.g.disable_autoformat and "desligado" or "ligado"))
  end, { desc = "[Formatação] Alternar formatar ao salvar" })
end)
-- Formata ao salvar. Sem o format_on_save do conform: ele só registra o BufWritePre no setup, tarde
-- demais para o primeiro :w, que é o que carrega o plugin.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(ev)
    if vim.g.disable_autoformat or vim.b[ev.buf].disable_autoformat then return end
    load_conform()
    require("conform").format({ bufnr = ev.buf, timeout_ms = 1000 })
  end,
})
lazy.cmds(load_conform, { "ConformInfo" })
lazy.keys(load_conform, {
  {
    "<leader>cf",
    function() require("conform").format({ async = true }) end,
    mode = { "n", "x" },
    desc = "[Formatação] Formatar arquivo/seleção",
  },
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = group,
  once = true,
  callback = lazy.loader({ "nvim-lint" }, function()
    local lint = require("lint")
    local wanted = {
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      dockerfile = { "hadolint" },
      yaml = { "actionlint" },
    }
    -- Só usa linters instalados, para não encher de erro.
    lint.linters_by_ft = {}
    for ft, names in pairs(wanted) do
      lint.linters_by_ft[ft] = vim.tbl_filter(function(n)
        local l = lint.linters[n]
        local cmd = type(l) == "table" and l.cmd or n
        return vim.fn.executable(type(cmd) == "function" and n or cmd) == 1
      end, names)
    end
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("pcastr.lint", { clear = true }),
      callback = function(ev)
        -- actionlint só nos workflows do GitHub
        if vim.bo[ev.buf].filetype == "yaml" and not ev.file:match("%.github/workflows/") then return end
        lint.try_lint()
      end,
    })
    lint.try_lint()
  end),
})
