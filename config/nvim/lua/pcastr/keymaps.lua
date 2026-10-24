-- Teclas do editor que não dependem de plugin.
-- As de cada plugin ficam junto do plugin (lua/pcastr/plugins/*.lua).
-- Lista completa e organizada: docs/neovim.md, ou <leader>? dentro do Neovim.
local map = vim.keymap.set

-- Básico
map("i", "jk", "<Esc>", { desc = "Sair do modo de inserção" })
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

-- Mover a seleção (J/K no modo visual) e manter a seleção ao indentar. Sem Alt: o Alt é do niri.
map("x", "J", ":m '>+1<cr>gv=gv", { desc = "Mover seleção para baixo", silent = true })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "Mover seleção para cima", silent = true })
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Colar sem perder o que estava copiado
map("x", "p", '"_dP', { desc = "Colar mantendo o registro" })

-- Copiar o caminho do arquivo (para colar num agente, chat ou terminal).
-- Vai para o clipboard do sistema; por SSH, o Neovim usa OSC 52 sozinho.
local function copy_path(desc, fn)
  return function()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then return vim.notify("Buffer sem arquivo", vim.log.levels.WARN) end
    local text = fn(file)
    vim.fn.setreg("+", text)
    vim.notify(desc .. ": " .. text)
  end
end
local function relative(f) return vim.fn.fnamemodify(f, ":.") end
map("n", "<leader>yp", copy_path("Caminho relativo", relative), { desc = "Copiar caminho relativo" })
map("n", "<leader>yP", copy_path("Caminho absoluto", function(f) return f end), { desc = "Copiar caminho absoluto" })
map(
  "n",
  "<leader>yn",
  copy_path("Nome", function(f) return vim.fn.fnamemodify(f, ":t") end),
  { desc = "Copiar nome do arquivo" }
)
map(
  "n",
  "<leader>yl",
  copy_path("Caminho com linha", function(f) return relative(f) .. ":" .. vim.fn.line(".") end),
  { desc = "Copiar caminho:linha" }
)
map("x", "<leader>yl", function()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  if a > b then
    a, b = b, a
  end
  local text = relative(vim.api.nvim_buf_get_name(0)) .. ":" .. a .. (a ~= b and ("-" .. b) or "")
  vim.fn.setreg("+", text)
  vim.notify("Caminho com linhas: " .. text)
end, { desc = "Copiar caminho:linhas da seleção" })

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
