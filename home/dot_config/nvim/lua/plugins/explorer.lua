-- Explorer: o oil abre a pasta como um texto. Renomear é editar o nome, apagar é dd, mover é dd e p em outra
-- pasta, copiar é yy e p, criar é escrever uma linha nova (com / no fim é pasta). O :w aplica. docs/neovim.md.

vim.pack.add({ "https://github.com/stevearc/oil.nvim" }, { confirm = false })

require("oil").setup({
  -- Apagar manda para a lixeira (dá para desfazer).
  delete_to_trash = true,
  -- Renomear ou mover um arquivo só não pede confirmação; apagar e mudanças maiores pedem.
  skip_confirm_for_simple_edits = true,
  -- Atualiza sozinho quando um arquivo muda fora do Neovim.
  watch_for_changes = true,
  view_options = { show_hidden = true },
  keymaps = {
    -- Ctrl+j/k/l/; são da navegação entre janelas (navigation.lua).
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-s>"] = false,
    ["<C-t>"] = false,
    ["gR"] = "actions.refresh",
    ["gv"] = { "actions.select", opts = { vertical = true }, desc = "Abrir ao lado" },
    ["gh"] = { "actions.select", opts = { horizontal = true }, desc = "Abrir embaixo" },
  },
})

local map = vim.keymap.set
map("n", "-", "<cmd>Oil<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
map("n", "<leader>E", function() require("oil").open(vim.fn.getcwd()) end, { desc = "[Explorer] Raiz do projeto" })
