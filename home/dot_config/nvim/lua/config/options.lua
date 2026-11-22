-- Opções gerais.

-- Nada de swap (.swp) nem backup (arquivo~): o git guarda o histórico.
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

-- Menu de sugestões na linha de comando (o que abre o menu enquanto digita fica em search.lua).
vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,fuzzy"

-- :grep pelo rg, com os arquivos ocultos e sem o .git nem o que o git ignora.
vim.o.grepprg = "rg --vimgrep --smart-case --hidden --glob=!.git/"

-- Árvore de pastas (netrw), sem o cabeçalho.
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
