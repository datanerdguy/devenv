-- Opções gerais.

-- Números das linhas: a atual mostra o número dela; as outras, a distância até ela (para 5j, 3k...).
vim.o.number = true
vim.o.relativenumber = true

-- Nada de swap (.swp) nem backup (arquivo~): o git guarda o histórico.
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

-- Menu fuzzy na linha de comando (: / ?), que aparece enquanto você digita (:help cmdline-autocompletion).
vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,fuzzy"
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", "?" },
  callback = function() vim.fn.wildtrigger() end,
})
-- Com o menu aberto, as setas saem dele e andam no histórico, como sem o menu.
local function history(key)
  return function() return vim.fn.wildmenumode() == 1 and "<C-e>" .. key or key end
end
vim.keymap.set("c", "<Up>", history("<Up>"), { expr = true })
vim.keymap.set("c", "<Down>", history("<Down>"), { expr = true })
