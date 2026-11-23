-- Treesitter: o nvim-treesitter só instala os parsers e as queries; o realce, o fold e o realce de uma linguagem
-- dentro de outra (SQL no Python, JS no HTML) são do Neovim. Compilar um parser pede o tree-sitter-cli (grupo
-- editor) e um compilador C.

-- Depois de atualizar o plugin, os parsers precisam ser atualizados junto (as queries mudam com ele).
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name ~= "nvim-treesitter" or ev.data.kind ~= "update" then return end
    if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
    vim.cmd("TSUpdate")
  end,
})

vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })

-- As linguagens são as dos servidores LSP ligados (plugins/lsp.lua), mais as que aparecem dentro de outras. O
-- tailwindcss e o htmx ficam de fora: eles entram em dezenas de tipos de arquivo de outros (svelte, twig, erb...).
local languages = { "comment", "diff", "gitcommit", "markdown_inline", "regex", "sql" }
local available = require("nvim-treesitter").get_available()
local guests = { tailwindcss = true, htmx = true }
for _, server in ipairs(require("plugins.lsp").servers) do
  local filetypes = not guests[server] and vim.lsp.config[server].filetypes or {}
  for _, filetype in ipairs(filetypes) do
    local language = vim.treesitter.language.get_lang(filetype)
    if vim.list_contains(available, language) then table.insert(languages, language) end
  end
end
languages = vim.list.unique(languages)

-- Só baixa o que falta; o que já está instalado não faz nada. Sem o tree-sitter-cli não dá para compilar: um aviso
-- só, em vez de um erro por linguagem.
if vim.fn.executable("tree-sitter") == 1 then
  require("nvim-treesitter").install(languages)
else
  vim.notify("Treesitter: falta o tree-sitter-cli (sudo pacman -S tree-sitter-cli)", vim.log.levels.WARN)
end

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- O arquivo abre com tudo aberto; zc fecha um bloco, zM fecha todos.
vim.o.foldlevelstart = 99

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("devenv_treesitter", {}),
  callback = function(ev)
    -- Sem parser para a linguagem, fica o realce antigo, por regex.
    if vim.treesitter.language.add(vim.treesitter.language.get_lang(ev.match) or ev.match) then
      vim.treesitter.start(ev.buf)
    end
  end,
})

return { languages = languages }
