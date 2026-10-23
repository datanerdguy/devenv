-- Teclas do editor que não dependem de plugin.
-- As de cada plugin ficam junto do plugin (lua/devenv/plugins/*.lua).
-- Lista completa e organizada: docs/neovim.md, ou <leader>? dentro do Neovim.
local map = vim.keymap.set

-- Básico
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Limpa destaque da busca" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Salvar" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Fechar janela" })
map("n", "<leader>Q", "<cmd>qall<cr>", { desc = "Sair do Neovim" })
map("n", "<leader>R", "<cmd>restart<cr>", { desc = "Reiniciar o Neovim (mantém a sessão)" })

-- Movimento em linhas quebradas e centralização
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "<C-d>", "<C-d>zz", { desc = "Meia página para baixo" })
map("n", "<C-u>", "<C-u>zz", { desc = "Meia página para cima" })
map("n", "n", "nzzzv", { desc = "Próximo resultado" })
map("n", "N", "Nzzzv", { desc = "Resultado anterior" })

-- Mover linhas (Alt+j/k) e manter seleção ao indentar
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Mover linha para baixo" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Mover linha para cima" })
map("x", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Mover seleção para baixo", silent = true })
map("x", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Mover seleção para cima", silent = true })
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Colar sem perder o que estava copiado
map("x", "p", '"_dP', { desc = "Colar mantendo o registro" })

-- Janelas (navegação C-h/j/k/l fica com o smart-splits, integrado ao tmux)
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Dividir abaixo" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Dividir à direita" })
map("n", "<leader>=", "<C-w>=", { desc = "Igualar janelas" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer anterior" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Próximo buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternar com o último buffer" })

-- Quickfix
map("n", "]q", "<cmd>cnext<cr>", { desc = "Próximo item do quickfix" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Item anterior do quickfix" })

-- Diagnósticos (o padrão do 0.11+ já tem ]d [d)
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnóstico da linha" })

-- Alternâncias da interface
local function toggle(opt, desc, key)
  map("n", key, function()
    vim.opt_local[opt] = not vim.opt_local[opt]:get()
    vim.notify(desc .. ": " .. (vim.opt_local[opt]:get() and "ligado" or "desligado"))
  end, { desc = "Alternar " .. desc })
end
toggle("wrap", "quebra de linha", "<leader>uw")
toggle("spell", "corretor", "<leader>us")
toggle("relativenumber", "número relativo", "<leader>ur")
map(
  "n",
  "<leader>uh",
  function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  { desc = "Alternar inlay hints" }
)
map(
  "n",
  "<leader>ud",
  function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
  { desc = "Alternar diagnósticos" }
)

-- Terminal: Esc duplo volta ao modo normal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Sair do modo terminal" })
