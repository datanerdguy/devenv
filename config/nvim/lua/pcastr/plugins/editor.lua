-- Edição: treesitter, git na margem, navegação integrada ao tmux.
local lazy = require("pcastr.lazy")
local gh = function(x) return "https://github.com/" .. x end

-- Parsers instalados junto com o nvim-treesitter (e de novo a cada atualização dele).
local parsers = {
  "bash",
  "css",
  "diff",
  "dockerfile",
  "elixir",
  "fish",
  "git_config",
  "gitcommit",
  "go",
  "heex",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "nix",
  "python",
  "query",
  "regex",
  "rust",
  "sql",
  "toml",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

lazy.on_change("nvim-treesitter", function()
  vim.cmd.TSUpdate()
  if vim.fn.executable("tree-sitter") == 1 then require("nvim-treesitter").install(parsers) end
end)

-- O nvim-treesitter não carrega sob demanda; o plugin/ dele é leve. vim-tmux-navigator: C-h/j/k/l
-- anda entre janelas do Neovim e painéis do tmux (o lado do tmux está em modules/tmux/tmux.conf).
vim.pack.add({
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  gh("christoomey/vim-tmux-navigator"),
}, { confirm = false })

local function ts_start(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then return end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

local tried = {} ---@type table<string, true>
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("pcastr.treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then return end
    if vim.treesitter.language.add(lang) then
      -- Depois de a tela desenhar: compilar as queries custa ~40 ms no primeiro arquivo de cada linguagem.
      vim.schedule(function() ts_start(ev.buf, lang) end)
      return
    end
    -- Parser ainda não instalado: instala em segundo plano e liga depois.
    if tried[lang] or vim.env.DEVENV_NVIM_TEST or vim.fn.executable("tree-sitter") == 0 then return end
    tried[lang] = true
    local ts = require("nvim-treesitter")
    if not vim.list_contains(ts.get_available(), lang) then return end
    ts.install({ lang }):await(function() ts_start(ev.buf, lang) end)
  end,
})

-- Fixa no topo a função/classe em que o cursor está (até 3 linhas). <leader>uc liga e desliga; [C vai até ela.
-- gitsigns: hunks na margem. Os dois só no primeiro arquivo.
lazy.install({ gh("nvim-treesitter/nvim-treesitter-context"), gh("lewis6991/gitsigns.nvim") })
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("pcastr.editor", { clear = true }),
  once = true,
  callback = lazy.loader({ "nvim-treesitter-context", "gitsigns.nvim" }, function()
    local ctx = require("treesitter-context")
    ctx.setup({ max_lines = 3, multiline_threshold = 1, trim_scope = "inner" })
    vim.keymap.set("n", "<leader>uc", ctx.toggle, { desc = "[UI] Alternar contexto da função no topo" })
    vim.keymap.set(
      "n",
      "[C",
      function() ctx.go_to_context(vim.v.count1) end,
      { desc = "[Navegação] Ir ao contexto (função/classe)" }
    )

    require("gitsigns").setup({
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buf = buf, desc = desc }) end
        map("n", "]h", function() gs.nav_hunk("next") end, "[Git/Hunk] Próximo")
        map("n", "[h", function() gs.nav_hunk("prev") end, "[Git/Hunk] Anterior")
        map({ "n", "x" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>", "[Git/Hunk] Stage")
        map({ "n", "x" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", "[Git/Hunk] Desfazer (reset)")
        map("n", "<leader>hS", gs.stage_buffer, "[Git/Hunk] Stage do arquivo inteiro")
        map("n", "<leader>hp", gs.preview_hunk_inline, "[Git/Hunk] Pré-visualizar")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "[Git/Hunk] Blame da linha")
        map("n", "<leader>hd", gs.diffthis, "[Git/Hunk] Diff do arquivo")
        map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<cr>", "[Git/Hunk] Textobject (ih)")
      end,
    })
  end),
})

-- Fecha e renomeia a tag par em HTML, HEEx (Phoenix), templates do Django/Go e JSX.
lazy.install({ gh("windwp/nvim-ts-autotag") })
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("pcastr.autotag", { clear = true }),
  pattern = {
    "html",
    "heex",
    "eex",
    "htmldjango",
    "gotmpl",
    "templ",
    "javascriptreact",
    "typescriptreact",
    "xml",
    "svelte",
    "vue",
  },
  once = true,
  -- O buffer que disparou a carga já passou do FileType; o autotag se liga nele no InsertEnter.
  callback = lazy.loader({ "nvim-ts-autotag" }, function() require("nvim-ts-autotag").setup() end),
})

-- Ctrl+setas redimensiona a janela (no lugar do smart-splits).
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "[Janela] Diminuir a largura" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "[Janela] Aumentar a largura" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "[Janela] Diminuir a altura" })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "[Janela] Aumentar a altura" })

-- Avisa o tmux que este painel é o Neovim, para Ctrl-h/j/k/l chegarem aqui (modules/tmux/tmux.conf).
if vim.env.TMUX then
  local function pane_is_vim(on)
    local args = on and { "tmux", "set-option", "-pq", "@pane-is-vim", "1" }
      or { "tmux", "set-option", "-pqu", "@pane-is-vim" }
    vim.system(args, { detach = not on })
  end
  local group = vim.api.nvim_create_augroup("pcastr.tmux", { clear = true })
  vim.api.nvim_create_autocmd(
    { "VimEnter", "VimResume" },
    { group = group, callback = function() pane_is_vim(true) end }
  )
  vim.api.nvim_create_autocmd(
    { "VimLeavePre", "VimSuspend" },
    { group = group, callback = function() pane_is_vim(false) end }
  )
end
