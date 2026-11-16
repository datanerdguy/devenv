---
name: nvim-lua
description: Regras para escrever e revisar o Lua da config do Neovim (config/nvim, tests/nvim) no Neovim 0.12/0.13 nightly. Use ao criar ou mudar arquivos .lua da config, ao revisar um diff do Neovim, ou ao trocar o jeito de carregar plugins.
---

# Lua da config do Neovim

Antes de dizer que terminou, rode os três portões. Os três precisam passar.

1. `agents/skills/nvim-lua/check-api.sh`: APIs removidas ou deprecadas na nightly. Corrija com o que ele indica.
2. `DEVENV_NVIM_TEST=1 nvim --headless -l tests/nvim/check.lua`: carrega tudo sem erro.
3. `tests/nvim/startup.sh`: abertura abaixo de 80 ms. Compare com a `dev` alternando as rodadas, nunca uma medida só.

Fora do sandbox, ou com `-i NONE`: dentro dele o ShaDa e o cache do `vim.loader` são só de leitura e o teste mede outra coisa.

## Regras

- **Módulos.** `local M = {} ... return M`, tudo `local`. Requerer um módulo não pode ter efeito: autocmd, keymap e `vim.pack.add` ficam no `init.lua`, nos arquivos de `plugins/` ou numa função chamada de propósito. Sem globais, fora as dos plugins (`Snacks`, `MiniIcons`).
- **Carga.** `vim.loader.enable()` na primeira linha do `init.lua`. Colorscheme e statusline carregam na abertura; o resto vai para um gatilho. `require` de plugin opcional fica dentro do callback (`function() require("x").y() end`), nunca no topo.
- **Sob demanda com vim.pack.** `load = false` dentro do `init.lua` ainda roda o `plugin/` na abertura. Para adiar de verdade, chame `vim.cmd.packadd(nome)` no gatilho e depois o `setup()`. Se o plugin tem `ftplugin/`, dispare de novo o `FileType` no buffer aberto (`nvim_exec_autocmds("FileType", { buf = buf })`). O nvim-treesitter não aceita carga sob demanda.
- **APIs.** `buf =` e não `buffer =` em keymap e autocmd. Todo keymap com `desc` no padrão `[Categoria] Ação`. Todo autocmd num `augroup` com `clear = true`. `vim.uv`, `vim.hl`, `vim.diagnostic.jump`, `vim.lsp.config`/`vim.lsp.enable`, `vim.fs.joinpath`, `vim.system`. Bordas pelo `winborder`, não por janela. `vim.opt.x:append({ ... })` com tabela: a 0.13 quebrou o encadeamento com operadores.
- **ui2.** Altura, tempo e pager das mensagens ficam no `messagesopt` (`timeout`, `maxheight`, `pager`). As chaves antigas da `ui2.enable()` dão erro.
- **Erros.** `pcall` só na fronteira: plugin opcional, `setup()` de terceiro, arquivo externo, entrada do usuário. Use o erro: `vim.notify(msg, vim.log.levels.ERROR)`. Nunca `pcall` para calar código nosso.
- **Tipos.** Anote só a fronteira: specs, tabelas de opções, funções de `M`. Classes com prefixo `pcastr.`. `---@diagnostic disable-next-line` pontual, nunca no arquivo inteiro.
- **Lua 5.1.** `unpack`, não `table.unpack`. Sem `goto`. `ffi` só com `if jit`.
- **Formato.** `stylua --config-path config/nvim/.stylua.toml` (o `just lint` roda). Sem selene: ferramenta nova pede comparação antes (AGENTS.md).
- **Testes.** `nvim --headless -l`, não plenary (sem manutenção). Afirme comportamento: `vim.fn.maparg(lhs, "n", false, true).desc` (com o `<leader>` já expandido), `vim.fn.exists(":Cmd") == 2`, `vim.g.colors_name`. Em headless o `UIEnter` não dispara: o que for adiado para ele fica fora da medida da abertura.

O porquê e a fonte de cada regra estão em [REFERENCIA.md](REFERENCIA.md).
