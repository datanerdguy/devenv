-- Buscar arquivos e texto pela linha de comando, com um menu fuzzy enquanto digita.
-- Receitas da ajuda: :help cmdline-autocompletion e :help fuzzy-file-picker.

-- O menu aparece sozinho em : / e ?.
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", "?" },
  callback = function() vim.fn.wildtrigger() end,
})
-- Com o menu aberto, as setas saem dele e andam no histórico, como sem o menu.
vim.keymap.set("c", "<Up>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Up>" or "<Up>" end, { expr = true })
vim.keymap.set("c", "<Down>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>" end, { expr = true })

-- :find lista os arquivos pelo fd (ocultos sim; .git e o que o git ignora não) e filtra fuzzy.
-- A lista é refeita a cada vez que a linha de comando abre.
local files
vim.o.findfunc = function(query)
  files = files or vim.fn.systemlist({ "fd", "--type", "file", "--hidden", "--exclude", ".git" })
  return query == "" and files or vim.fn.matchfuzzy(files, query)
end
vim.api.nvim_create_autocmd("CmdlineEnter", { pattern = ":", callback = function() files = nil end })

-- :Recent: os arquivos abertos antes (que ainda existem), no mesmo menu do :find.
vim.api.nvim_create_user_command("Recent", function(o) vim.cmd.edit(o.args) end, {
  nargs = 1,
  complete = function(query)
    local recent = vim.tbl_filter(function(f) return vim.fn.filereadable(f) == 1 end, vim.v.oldfiles)
    recent = vim.tbl_map(function(f) return vim.fn.fnamemodify(f, ":~:.") end, recent)
    return query == "" and recent or vim.fn.matchfuzzy(recent, query)
  end,
})

-- No :find, :b e :Recent, o Enter sem escolher nada abre a primeira sugestão.
vim.api.nvim_create_autocmd("CmdlineLeavePre", {
  pattern = ":",
  callback = function()
    local cmd = vim.fn.getcmdline():match("^%s*(%a+)%s")
    local info = vim.fn.cmdcomplete_info()
    if vim.list_contains({ "fin", "find", "b", "buffer", "Recent" }, cmd) and info.selected == -1 and #(info.matches or {}) > 0 then
      vim.fn.setcmdline(cmd .. " " .. info.matches[1])
    end
  end,
})

-- O resultado do :grep abre no quickfix.
vim.api.nvim_create_autocmd("QuickFixCmdPost", { pattern = "grep", command = "cwindow" })
