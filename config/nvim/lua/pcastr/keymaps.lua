-- Teclas do editor que não dependem de plugin.
-- As de cada plugin ficam junto do plugin (lua/pcastr/plugins/*.lua).
-- Lista completa e organizada: docs/neovim.md, ou <leader>? dentro do Neovim.
local map = vim.keymap.set

-- Básico
map("i", "jk", "<Esc>", { desc = "[Geral] Sair do modo de inserção (jk)" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "[Geral] Limpar destaque da busca" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "[Arquivo] Salvar" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "[Janela] Fechar janela" })
map("n", "<leader>Q", "<cmd>qall<cr>", { desc = "[Geral] Sair do Neovim" })
map("n", "<leader>R", "<cmd>restart<cr>", { desc = "[Geral] Reiniciar o Neovim (mantém a sessão)" })

-- Movimento em linhas quebradas e centralização
map(
  { "n", "x" },
  "j",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true, desc = "[Navegação] Linha abaixo (visual se houver quebra)" }
)
map(
  { "n", "x" },
  "k",
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true, desc = "[Navegação] Linha acima (visual se houver quebra)" }
)
map("n", "<C-d>", "<C-d>zz", { desc = "[Navegação] Meia página para baixo (centralizado)" })
map("n", "<C-u>", "<C-u>zz", { desc = "[Navegação] Meia página para cima (centralizado)" })
map("n", "n", "nzzzv", { desc = "[Busca] Próximo resultado (centralizado)" })
map("n", "N", "Nzzzv", { desc = "[Busca] Resultado anterior (centralizado)" })

-- Mover a seleção (J/K no modo visual) e manter a seleção ao indentar. Sem Alt: o Alt é do niri.
map("x", "J", ":m '>+1<cr>gv=gv", { desc = "[Edição] Mover seleção para baixo", silent = true })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "[Edição] Mover seleção para cima", silent = true })
map("x", "<", "<gv", { desc = "[Edição] Desindentar e manter seleção" })
map("x", ">", ">gv", { desc = "[Edição] Indentar e manter seleção" })

-- Colar sem perder o que estava copiado
map("x", "p", '"_dP', { desc = "[Edição] Colar sem perder o registro" })

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
map("n", "<leader>yp", copy_path("Caminho relativo", relative), { desc = "[Copiar] Caminho relativo do arquivo" })
map(
  "n",
  "<leader>yP",
  copy_path("Caminho absoluto", function(f) return f end),
  { desc = "[Copiar] Caminho absoluto do arquivo" }
)
map(
  "n",
  "<leader>yn",
  copy_path("Nome", function(f) return vim.fn.fnamemodify(f, ":t") end),
  { desc = "[Copiar] Nome do arquivo" }
)
map(
  "n",
  "<leader>yl",
  copy_path("Caminho com linha", function(f) return relative(f) .. ":" .. vim.fn.line(".") end),
  { desc = "[Copiar] Caminho:linha" }
)
map("x", "<leader>yl", function()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  if a > b then
    a, b = b, a
  end
  local text = relative(vim.api.nvim_buf_get_name(0)) .. ":" .. a .. (a ~= b and ("-" .. b) or "")
  vim.fn.setreg("+", text)
  vim.notify("Caminho com linhas: " .. text)
end, { desc = "[Copiar] Caminho:linhas da seleção" })

-- Janelas (navegação C-h/j/k/l fica com o smart-splits, integrado ao tmux)
map("n", "<leader>-", "<cmd>split<cr>", { desc = "[Janela] Dividir abaixo" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "[Janela] Dividir à direita" })
map("n", "<leader>=", "<C-w>=", { desc = "[Janela] Igualar tamanhos" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "[Buffer] Anterior" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "[Buffer] Próximo" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "[Buffer] Alternar com o último" })

-- Quickfix
map("n", "]q", "<cmd>cnext<cr>", { desc = "[Quickfix] Próximo item" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "[Quickfix] Item anterior" })

-- Diagnósticos (o padrão do 0.11+ já tem ]d [d)
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "[Diagnóstico] Mostrar da linha" })

-- Alternâncias da interface
local function toggle(opt, desc, key)
  map("n", key, function()
    ---@diagnostic disable-next-line: assign-type-mismatch -- opt é dinâmico
    vim.wo[0][opt] = not vim.wo[0][opt]
    vim.notify(desc .. ": " .. (vim.wo[0][opt] and "ligado" or "desligado"))
  end, { desc = "[UI] Alternar " .. desc })
end
toggle("wrap", "quebra de linha", "<leader>uw")
toggle("spell", "corretor", "<leader>us")
toggle("relativenumber", "número relativo", "<leader>ur")
map(
  "n",
  "<leader>uh",
  function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  { desc = "[LSP] Alternar inlay hints" }
)
map(
  "n",
  "<leader>ud",
  function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
  { desc = "[Diagnóstico] Alternar exibição" }
)

-- Terminal: Esc duplo volta ao modo normal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "[Terminal] Sair do modo terminal (Esc Esc)" })
