-- Buscar arquivos, pastas e texto pelo fzf-lua: o mesmo fzf do shell, com prévia. Os atalhos ficam no fim.

vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-web-devicons",
}, { confirm = false })

local fzf = require("fzf-lua")
fzf.setup({
  fzf_colors = true,
  ui_select = {},
  -- Modo normal, como no Vim: Esc para de escrever (o prompt ganha "NORMAL"), j/k andam na lista, i volta a escrever
  -- e q ou Esc fecham. O fzf não tem modos; o Esc liga as teclas j, k, i e q, e o i as desliga de novo.
  -- O perfil padrão do fzf-lua prende o Esc para só esconder a janela; aqui o Esc é do modo normal.
  defaults = { no_hide = true },
  keymap = {
    fzf = {
      true, -- mantém os atalhos padrão do fzf-lua
      ["start"] = "+unbind(j,k,i,q)",
      ["esc"] = [[transform:case "$FZF_PROMPT" in "NORMAL "*) echo abort ;; *) echo "rebind(j,k,i,q)+change-prompt(NORMAL $FZF_PROMPT)" ;; esac]],
      ["i"] = [[transform:echo "unbind(j,k,i,q)+change-prompt(${FZF_PROMPT#NORMAL })"]],
      ["j"] = "down",
      ["k"] = "up",
      ["q"] = "abort",
    },
  },
  -- Prompts curtos, como os do fzf no shell (pasta ❯, tema ❯...), sem a pasta atual abreviada (~/P/d/h/...).
  files = { hidden = true, cwd_prompt = false, prompt = "arquivo ❯ " },
  grep = { hidden = true, prompt = "texto ❯ " },
  buffers = { prompt = "aberto ❯ " },
  oldfiles = { prompt = "recente ❯ " },
  blines = { prompt = "linha ❯ " },
  zoxide = { prompt = "zoxide ❯ " },
})

-- Pastas do projeto (fd), e a escolhida abre no explorer (oil).
local function folders()
  fzf.fzf_exec("fd --type directory --hidden --exclude .git", {
    prompt = "pasta ❯ ",
    actions = {
      enter = function(selected) require("oil").open(selected[1]) end,
    },
  })
end

-- Pastas que o zoxide conhece (as que você mais usa, de qualquer projeto), abertas no explorer.
local function zoxide()
  fzf.zoxide({ actions = {
    enter = function(selected) require("oil").open(selected[1]:match("[^\t]+$")) end,
  } })
end

local map = vim.keymap.set
map("n", "<leader>ff", fzf.files, { desc = "[Buscar] Arquivos" })
map("n", "<leader>fd", folders, { desc = "[Buscar] Pastas do projeto" })
map("n", "<leader>fz", zoxide, { desc = "[Buscar] Pastas do zoxide" })
map("n", "<leader>/", fzf.blines, { desc = "[Buscar] Texto no arquivo atual" })
map("n", "<leader>fg", fzf.live_grep, { desc = "[Buscar] Texto no projeto" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "[Buscar] Palavra do cursor" })
map("n", "<leader>fb", fzf.buffers, { desc = "[Buscar] Arquivos abertos" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "[Buscar] Recentes" })
map("n", "<leader>fe", fzf.diagnostics_document, { desc = "[Buscar] Erros do arquivo" })
map("n", "<leader>fE", fzf.diagnostics_workspace, { desc = "[Buscar] Erros do projeto" })
map("n", "<leader>fh", fzf.helptags, { desc = "[Buscar] Ajuda do Neovim" })
map("n", "<leader>fk", fzf.keymaps, { desc = "[Buscar] Atalhos" })
map("n", "<leader>f.", fzf.resume, { desc = "[Buscar] Voltar à última busca" })
