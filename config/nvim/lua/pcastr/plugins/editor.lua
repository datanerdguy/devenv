-- Edição: treesitter, git na margem, navegação integrada ao tmux.
local pack = require("pcastr.pack")
local gh = function(x) return "https://github.com/" .. x end

-- Parsers instalados na primeira vez que o treesitter carrega (em segundo plano).
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

pack.add({
  {
    src = gh("nvim-treesitter/nvim-treesitter"),
    version = "main",
    ft = "*",
    build = function() pcall(vim.cmd.TSUpdate) end,
    config = function()
      local ts = require("nvim-treesitter")
      local available = {}
      for _, l in ipairs(ts.get_available()) do
        available[l] = true
      end
      local installed = {}
      for _, l in ipairs(ts.get_installed()) do
        installed[l] = true
      end

      local function start(buf, lang)
        if pcall(vim.treesitter.start, buf, lang) then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("pcastr.treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or not available[lang] then return end
          if installed[lang] then return start(ev.buf, lang) end
          -- Parser ainda não instalado: instala em segundo plano e liga depois.
          if vim.env.DEVENV_NVIM_TEST or vim.fn.executable("tree-sitter") == 0 then return end
          installed[lang] = true
          ts.install({ lang }):await(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then start(ev.buf, lang) end
          end)
        end,
      })

      if not vim.env.DEVENV_NVIM_TEST and vim.fn.executable("tree-sitter") == 1 then
        local missing = vim.tbl_filter(function(l) return not installed[l] end, parsers)
        if #missing > 0 then ts.install(missing) end
      end
    end,
  },

  -- Fixa no topo a função/classe em que o cursor está (até 3 linhas). <leader>uc liga e desliga; [C vai até ela.
  {
    src = gh("nvim-treesitter/nvim-treesitter-context"),
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ctx = require("treesitter-context")
      ctx.setup({ max_lines = 3, multiline_threshold = 1, trim_scope = "inner" })
      vim.keymap.set("n", "<leader>uc", ctx.toggle, { desc = "[UI] Alternar contexto da função no topo" })
      vim.keymap.set(
        "n",
        "[C",
        function() ctx.go_to_context(vim.v.count1) end,
        { desc = "[Navegação] Ir ao contexto (função/classe)" }
      )
    end,
  },

  -- Fecha e renomeia a tag par em HTML, HEEx (Phoenix), templates do Django/Go e JSX.
  {
    src = gh("windwp/nvim-ts-autotag"),
    ft = {
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
    config = function() require("nvim-ts-autotag").setup() end,
  },

  {
    src = gh("lewis6991/gitsigns.nvim"),
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        on_attach = function(buf)
          local gs = require("gitsigns")
          local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buf, desc = desc }) end
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
    end,
  },

  -- C-h/j/k/l anda entre janelas do Neovim e painéis do tmux (plugin VimScript, sem setup em Lua).
  -- O lado do tmux está em modules/tmux/tmux.conf. Ctrl+setas redimensiona (smart-splits).
  { src = gh("christoomey/vim-tmux-navigator") },
  {
    src = gh("mrjones2014/smart-splits.nvim"),
    keys = {
      {
        "<C-Left>",
        function() require("smart-splits").resize_left() end,
        desc = "[Janela] Redimensionar para a esquerda",
      },
      {
        "<C-Right>",
        function() require("smart-splits").resize_right() end,
        desc = "[Janela] Redimensionar para a direita",
      },
      { "<C-Down>", function() require("smart-splits").resize_down() end, desc = "[Janela] Redimensionar para baixo" },
      { "<C-Up>", function() require("smart-splits").resize_up() end, desc = "[Janela] Redimensionar para cima" },
    },
    config = function() require("smart-splits").setup({ at_edge = "stop" }) end,
  },
})

-- Avisa o tmux que este painel é o Neovim, para Ctrl-h/j/k/l chegarem aqui (modules/tmux/tmux.conf).
-- Feito aqui, sem carregar o smart-splits, que só carrega na primeira tecla.
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
