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
    build = function() pcall(vim.cmd, "TSUpdate") end,
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
      vim.keymap.set("n", "<leader>uc", ctx.toggle, { desc = "Alternar contexto no topo" })
      vim.keymap.set("n", "[C", function() ctx.go_to_context(vim.v.count1) end, { desc = "Ir ao contexto" })
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
          map("n", "]h", function() gs.nav_hunk("next") end, "Próximo hunk")
          map("n", "[h", function() gs.nav_hunk("prev") end, "Hunk anterior")
          map({ "n", "x" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>", "Stage do hunk")
          map({ "n", "x" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", "Desfazer hunk")
          map("n", "<leader>hS", gs.stage_buffer, "Stage do arquivo")
          map("n", "<leader>hp", gs.preview_hunk_inline, "Ver hunk")
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame da linha")
          map("n", "<leader>hd", gs.diffthis, "Diff do arquivo")
          map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<cr>", "Hunk (textobject)")
        end,
      })
    end,
  },

  -- C-h/j/k/l anda entre janelas do Neovim e painéis do tmux sem diferença. Ctrl+setas redimensiona.
  {
    src = gh("mrjones2014/smart-splits.nvim"),
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Janela à esquerda" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Janela abaixo" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Janela acima" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Janela à direita" },
      { "<C-Left>", function() require("smart-splits").resize_left() end, desc = "Redimensionar ←" },
      { "<C-Right>", function() require("smart-splits").resize_right() end, desc = "Redimensionar →" },
      { "<C-Down>", function() require("smart-splits").resize_down() end, desc = "Redimensionar ↓" },
      { "<C-Up>", function() require("smart-splits").resize_up() end, desc = "Redimensionar ↑" },
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
