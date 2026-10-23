-- LSP nativo (vim.lsp.config / vim.lsp.enable).
--
-- Fluxo para ter um LSP novo funcionando, do mais fácil ao mais reproduzível:
--   1. :Mason e instale o servidor (fica em ~/.local/share/nvim/mason).
--   2. Ou deixe no devShell do projeto (flake.nix do projeto), ativado pelo direnv.
--   3. Ou acrescente em modules/nvim/default.nix (instalado em toda máquina).
-- Em todos os casos o servidor é ligado sozinho se o executável existir:
-- basta colocar o nome dele em `servers` abaixo (nomes do nvim-lspconfig, :help lspconfig-all).
local servers = {
  "lua_ls",
  "basedpyright",
  "ruff",
  "gopls",
  "rust_analyzer",
  "nixd",
  "marksman",
  "taplo",
  "yamlls",
  "jsonls",
  "bashls",
  "html",
  "cssls",
  "tailwindcss",
  "ts_ls",
  "expert", -- Elixir
  "dockerls",
}

-- Binários instalados pelo Mason entram no PATH sem carregar o plugin.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = vim.env.PATH .. ":" .. mason_bin -- depois do Nix/devShell: eles têm prioridade
end

-- Ajustes por servidor (o resto vem do nvim-lspconfig)
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      hint = { enable = true },
      completion = { callSnippet = "Replace" },
    },
  },
})
vim.lsp.config("basedpyright", {
  settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
})

local function executable(name)
  local cfg = vim.lsp.config[name]
  if not cfg then return false end
  local cmd = cfg.cmd
  if type(cmd) == "table" then return vim.fn.executable(cmd[1]) == 1 end
  return type(cmd) == "function" -- cmd dinâmico: confia na config
end

-- Liga os servidores na primeira vez que um arquivo abre (não pesa na abertura do Neovim).
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  group = vim.api.nvim_create_augroup("pcastr.lsp.enable", { clear = true }),
  callback = function() vim.lsp.enable(vim.tbl_filter(executable, servers)) end,
})

vim.api.nvim_create_user_command("LspServers", function()
  local lines = {}
  for _, s in ipairs(servers) do
    table.insert(lines, (executable(s) and "● " or "○ ") .. s)
  end
  vim.notify("Servidores (● instalado, ○ falta instalar):\n" .. table.concat(lines, "\n"))
end, { desc = "Lista os servidores LSP configurados e quais estão instalados" })

-- Teclas e recursos quando um servidor se conecta ao buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("pcastr.lsp.attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end
    local function map(lhs, rhs, desc, mode) vim.keymap.set(mode or "n", lhs, rhs, { buffer = ev.buf, desc = desc }) end
    map("<leader>ca", vim.lsp.buf.code_action, "Ações de código", { "n", "x" })
    map("<leader>cr", vim.lsp.buf.rename, "Renomear símbolo")
    map("<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "Estado do LSP")
    map("<leader>cR", "<cmd>lsp restart<cr>", "Reiniciar LSP")

    if client:supports_method("textDocument/inlayHint") then vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf }) end
    -- O Ruff cuida de lint/format; o hover fica com o basedpyright.
    if client.name == "ruff" then client.server_capabilities.hoverProvider = false end
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = false, -- quem mostra inline é o tiny-inline-diagnostic
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{f057} ",
      [vim.diagnostic.severity.WARN] = "\u{f071} ",
      [vim.diagnostic.severity.INFO] = "\u{f05a} ",
      [vim.diagnostic.severity.HINT] = "\u{f0eb} ",
    },
  },
})
