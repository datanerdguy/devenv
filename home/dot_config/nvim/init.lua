-- Neovim do devenv (docs/neovim.md). Só o que é nativo do Neovim 0.13, sem plugins.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Arquivos -------------------------------------------------------------------
-- Nada de swap (.swp) nem backup (arquivo~): o git guarda o histórico.
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

-- Linha de comando -----------------------------------------------------------
-- O menu de sugestões aparece enquanto você digita, em : / e ? (:help cmdline-autocompletion).
vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,fuzzy"
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", "?" },
  callback = function() vim.fn.wildtrigger() end,
})
-- Com o menu aberto, as setas saem dele e andam no histórico, como sem o menu.
vim.keymap.set("c", "<Up>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Up>" or "<Up>" end, { expr = true })
vim.keymap.set("c", "<Down>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>" end, { expr = true })

-- Buscar arquivos ------------------------------------------------------------
-- O :find lista os arquivos pelo fd (ocultos sim; .git e o que o git ignora não) e filtra fuzzy
-- (:help fuzzy-file-picker). A lista é refeita a cada vez que a linha de comando abre.
local arquivos
vim.o.findfunc = function(busca)
  arquivos = arquivos or vim.fn.systemlist({ "fd", "--type", "file", "--hidden", "--exclude", ".git" })
  return busca == "" and arquivos or vim.fn.matchfuzzy(arquivos, busca)
end
vim.api.nvim_create_autocmd("CmdlineEnter", { pattern = ":", callback = function() arquivos = nil end })

-- :Recentes: os arquivos abertos antes (que ainda existem), no mesmo menu fuzzy do :find.
vim.api.nvim_create_user_command("Recentes", function(o) vim.cmd.edit(o.args) end, {
  nargs = 1,
  complete = function(busca)
    local recentes = vim.tbl_filter(function(f) return vim.fn.filereadable(f) == 1 end, vim.v.oldfiles)
    recentes = vim.tbl_map(function(f) return vim.fn.fnamemodify(f, ":~:.") end, recentes)
    return busca == "" and recentes or vim.fn.matchfuzzy(recentes, busca)
  end,
})

-- No :find, :b e :Recentes, o Enter sem escolher nada abre a primeira sugestão.
vim.api.nvim_create_autocmd("CmdlineLeavePre", {
  pattern = ":",
  callback = function()
    local cmd = vim.fn.getcmdline():match("^%s*(%a+)%s")
    local info = vim.fn.cmdcomplete_info()
    if vim.list_contains({ "fin", "find", "b", "buffer", "Recentes" }, cmd) and info.selected == -1 and #(info.matches or {}) > 0 then
      vim.fn.setcmdline(cmd .. " " .. info.matches[1])
    end
  end,
})

-- Buscar texto ---------------------------------------------------------------
-- :grep pelo rg, com os arquivos ocultos e sem o .git nem o que o git ignora; o resultado abre no quickfix.
vim.o.grepprg = "rg --vimgrep --smart-case --hidden --glob=!.git/"
vim.api.nvim_create_autocmd("QuickFixCmdPost", { pattern = "grep", command = "cwindow" })

-- Árvore de pastas (netrw) ----------------------------------------------------
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3 -- árvore

-- Atalhos ---------------------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader>ff", ":find ", { desc = "[Buscar] Arquivos" })
map("n", "<leader>fg", ":silent grep ", { desc = "[Buscar] Texto no projeto" })
map("n", "<leader>fb", ":b ", { desc = "[Buscar] Arquivos abertos" })
map("n", "<leader>fr", ":Recentes ", { desc = "[Buscar] Recentes" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "[Explorer] Pasta do arquivo atual" })
-- Salva tudo e reinicia: a config é lida de novo, e os arquivos e janelas voltam como estavam.
map("n", "<leader>R", "<cmd>silent! wall | restart<cr>", { desc = "[Geral] Salvar e reiniciar o Neovim" })
