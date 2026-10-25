-- Interface (o tema fica em pcastr/theme.lua): ícones, statusline, snacks (picker, explorer, terminal...) e which-key.
local pack = require("pcastr.pack")
local gh = function(x) return "https://github.com/" .. x end

pack.add({
  -- mini.nvim: ícones e statusline já na abertura (são leves); o resto sob demanda.
  {
    src = gh("nvim-mini/mini.nvim"),
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
      require("mini.statusline").setup({ use_icons = true })
      vim.api.nvim_create_autocmd({ "InsertEnter", "BufReadPost" }, {
        once = true,
        callback = function()
          require("mini.ai").setup() -- textobjects extras: a( i" af if (função) etc.
          require("mini.surround").setup() -- sa sd sr: adicionar/apagar/trocar em volta
          require("mini.pairs").setup() -- fecha parênteses e aspas
        end,
      })
    end,
  },

  -- snacks.nvim: carrega na abertura, mas cada módulo só é usado quando chamado.
  {
    src = gh("folke/snacks.nvim"),
    config = function()
      require("snacks").setup({
        bigfile = { enabled = true }, -- arquivo grande: desliga o que pesa
        quickfile = { enabled = true }, -- mostra o arquivo antes dos plugins
        notifier = { enabled = true, timeout = 3000 },
        input = { enabled = true },
        indent = { enabled = true, animate = { enabled = false } },
        scope = { enabled = true },
        words = { enabled = true }, -- destaca a palavra sob o cursor (via LSP)
        dashboard = {
          enabled = true,
          preset = {
            keys = {
              { icon = "\u{f002} ", key = "f", desc = "Buscar arquivo", action = ":lua Snacks.picker.files()" },
              { icon = "\u{f0b0} ", key = "g", desc = "Buscar texto", action = ":lua Snacks.picker.grep()" },
              { icon = "\u{f1da} ", key = "r", desc = "Recentes", action = ":lua Snacks.picker.recent()" },
              { icon = "\u{f07b} ", key = "e", desc = "Explorer", action = ":lua Snacks.explorer()" },
              { icon = "\u{f1e6} ", key = "p", desc = "Plugins", action = ":Pack" },
              {
                icon = "\u{f013} ",
                key = "c",
                desc = "Config",
                action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })",
              },
              { icon = "\u{f011} ", key = "q", desc = "Sair", action = ":qa" },
            },
          },
          sections = { { section = "keys", gap = 1, padding = 1 } },
        },
        explorer = { enabled = true, replace_netrw = true },
        picker = {
          enabled = true,
          -- Mostra arquivos ocultos em tudo. Alt-h alterna ocultos, Alt-i alterna ignorados pelo git.
          hidden = true,
          sources = {
            files = { hidden = true },
            grep = { hidden = true },
            explorer = { hidden = true, ignored = false },
          },
        },
        terminal = { enabled = true },
        lazygit = { enabled = true },
        scratch = { enabled = true },
        zen = { enabled = true },
      })

      local map = vim.keymap.set
      local S = Snacks
      -- Busca (f)
      map("n", "<leader><space>", function() S.picker.smart() end, { desc = "[Busca] Arquivos (inteligente)" })
      map("n", "<leader>/", function() S.picker.lines() end, { desc = "[Busca] Texto no arquivo (grep)" })
      map("n", "<leader>ff", function() S.picker.files() end, { desc = "[Busca] Arquivos (inclui ocultos)" })
      map("n", "<leader>fg", function() S.picker.grep() end, { desc = "[Busca] Texto no projeto (grep)" })
      map({ "n", "x" }, "<leader>fw", function() S.picker.grep_word() end, { desc = "[Busca] Palavra sob o cursor" })
      map("n", "<leader>fb", function() S.picker.buffers() end, { desc = "[Busca] Buffers abertos" })
      map("n", "<leader>fr", function() S.picker.recent() end, { desc = "[Busca] Arquivos recentes" })
      map("n", "<leader>fh", function() S.picker.help() end, { desc = "[Busca] Ajuda do Neovim" })
      map("n", "<leader>fk", function() S.picker.keymaps() end, { desc = "[Busca] Atalhos (keymaps)" })
      map(
        "n",
        "<leader>fc",
        function() S.picker.files({ cwd = vim.fn.stdpath("config") }) end,
        { desc = "[Busca] Arquivos da config do Neovim" }
      )
      map("n", "<leader>fp", function() S.picker.projects() end, { desc = "[Busca] Projetos" })
      map("n", "<leader>fs", function() S.picker.lsp_symbols() end, { desc = "[Busca/LSP] Símbolos do arquivo" })
      map(
        "n",
        "<leader>fS",
        function() S.picker.lsp_workspace_symbols() end,
        { desc = "[Busca/LSP] Símbolos do projeto" }
      )
      map("n", "<leader>f.", function() S.picker.resume() end, { desc = "[Busca] Reabrir última busca" })
      map("n", "<leader>xx", function() S.picker.diagnostics() end, { desc = "[Diagnóstico] Lista do projeto" })
      map("n", "<leader>xb", function() S.picker.diagnostics_buffer() end, { desc = "[Diagnóstico] Lista do arquivo" })
      map("n", "<leader>xq", function() S.picker.qflist() end, { desc = "[Quickfix] Abrir lista" })
      map(
        "n",
        "<leader>xt",
        function() S.picker.grep({ search = [[\b(TODO|FIXME|HACK|NOTE)\b]], regex = true }) end,
        { desc = "[Busca] TODOs do projeto" }
      )

      -- Explorer (e)
      map("n", "<leader>e", function()
        local root = vim.fs.root(0, { ".git", "package.json", "Cargo.toml", "pyproject.toml" })
        Snacks.explorer({ cwd = root or vim.fn.getcwd() })
      end, { desc = "[explorer] abrir/fechar (root projeto)" })

      map("n", "<leader>E", function() S.explorer.reveal() end, { desc = "[Explorer] Revelar arquivo atual" })

      -- Git (g)
      map("n", "<leader>gg", function() S.lazygit() end, { desc = "[Git] Lazygit" })
      map("n", "<leader>gs", function() S.picker.git_status() end, { desc = "[Git] Arquivos alterados" })
      map("n", "<leader>gl", function() S.picker.git_log() end, { desc = "[Git] Log do projeto" })
      map("n", "<leader>gf", function() S.picker.git_log_file() end, { desc = "[Git] Log do arquivo" })
      map("n", "<leader>gB", function() S.gitbrowse() end, { desc = "[Git] Abrir no GitHub" })

      -- LSP com picker (o padrão do 0.11+ já tem grn, gra, grr, gri, gO, K)
      map("n", "gd", function() S.picker.lsp_definitions() end, { desc = "[LSP] Ir para definição" })
      map("n", "gD", function() S.picker.lsp_declarations() end, { desc = "[LSP] Ir para declaração" })
      map("n", "gy", function() S.picker.lsp_type_definitions() end, { desc = "[LSP] Ir para definição do tipo" })
      map("n", "gr", function() S.picker.lsp_references() end, { desc = "[LSP] Referências", nowait = true })
      map("n", "]]", function() S.words.jump(1, true) end, { desc = "[Navegação] Próxima ocorrência da palavra" })
      map("n", "[[", function() S.words.jump(-1, true) end, { desc = "[Navegação] Ocorrência anterior da palavra" })

      -- Terminal, buffers, extras
      map({ "n", "t" }, "<C-/>", function() S.terminal() end, { desc = "[Terminal] Abrir/fechar flutuante" })
      map("n", "<leader>bd", function() S.bufdelete() end, { desc = "[Buffer] Fechar" })
      map("n", "<leader>bo", function() S.bufdelete.other() end, { desc = "[Buffer] Fechar os outros" })
      map("n", "<leader>.", function() S.scratch() end, { desc = "[Arquivo] Rascunho (scratch)" })
      map("n", "<leader>uz", function() S.zen() end, { desc = "[UI] Alternar modo zen" })
      map("n", "<leader>un", function() S.notifier.show_history() end, { desc = "[UI] Histórico de notificações" })
    end,
  },

  -- which-key: mostra as teclas possíveis depois do <leader>.
  {
    src = gh("folke/which-key.nvim"),
    event = "UIEnter",
    config = function()
      local wk = require("which-key")
      wk.setup({ preset = "helix", delay = 300 })
      wk.add({
        { "<leader>a", group = "IA / agentes" },
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "código" },
        { "<leader>d", group = "debug" },
        { "<leader>D", group = "dados (SQL, tabelas)" },
        { "<leader>f", group = "buscar" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunks do git" },
        { "<leader>n", group = "notebooks" },
        { "<leader>p", group = "plugins" },
        { "<leader>u", group = "alternar interface" },
        { "<leader>x", group = "diagnósticos e listas" },
        { "<leader>y", group = "copiar caminho" },
        { "<leader>z", group = "notas (Obsidian)" },
        { "<leader>?", function() wk.show({ global = false }) end, desc = "[Geral] Atalhos deste buffer" },
      })
    end,
  },
})

-- Gerenciador de plugins (p)
vim.keymap.set("n", "<leader>pp", "<cmd>Pack<cr>", { desc = "[Plugins] Gerenciador" })
vim.keymap.set("n", "<leader>pc", "<cmd>Pack!<cr>", { desc = "[Plugins] Verificar atualizações" })
vim.keymap.set("n", "<leader>pu", "<cmd>PackUpdate<cr>", { desc = "[Plugins] Atualizar todos" })
vim.keymap.set("n", "<leader>ps", "<cmd>PackStatus<cr>", { desc = "[Plugins] Resumo e tempo de carga" })
