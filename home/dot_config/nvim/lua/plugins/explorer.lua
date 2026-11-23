-- Explorer: o oil abre a pasta como um texto. Renomear é editar o nome, apagar é dd, mover é dd e p em outra
-- pasta, copiar é yy e p, criar é escrever uma linha nova (com / no fim é pasta). O :w aplica. docs/neovim.md.

vim.pack.add({ "https://github.com/stevearc/oil.nvim" }, { confirm = false })

require("oil").setup({
  delete_to_trash = true,
  -- Renomear ou mover um arquivo só não pede confirmação; apagar e mudanças maiores pedem.
  skip_confirm_for_simple_edits = true,
  watch_for_changes = true,
  view_options = { show_hidden = true },
  keymaps = {
    -- O Ctrl-l é da navegação entre janelas (config/navigation.lua); atualizar a lista passa para gR.
    ["<C-l>"] = false,
    ["gR"] = "actions.refresh",
  },
})

local map = vim.keymap.set
map("n", "-", "<cmd>Oil<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
map("n", "<leader>E", function() require("oil").open(vim.fn.getcwd()) end, { desc = "[Explorer] Raiz do projeto" })
