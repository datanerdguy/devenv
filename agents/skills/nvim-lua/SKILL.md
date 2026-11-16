---
name: nvim-lua
description: Esta skill deve ser usada ao escrever, mudar ou revisar o Lua da config do Neovim (config/nvim, tests/nvim) no Neovim 0.13 nightly, e quando o pedido for "mexe no neovim", "adiciona um plugin do Neovim", "cria um keymap do Neovim", "revisa o Lua do nvim", "carrega esse plugin sob demanda" ou "essa API do Neovim está deprecada?". Traz um script que acha APIs removidas ou deprecadas, os portões de pronto e as regras de estilo, carga e testes. Não serve para tmux, niri, sway ou outras áreas do devenv.
---

# Lua da config do Neovim

Rode os quatro portões antes de dizer que terminou. Os quatro precisam passar.

1. `agents/skills/nvim-lua/scripts/check-api.sh` procura APIs removidas ou deprecadas na nightly e indica o que usar no lugar. Ele sai com 1 quando acha algo.
2. `DEVENV_NVIM_TEST=1 nvim --headless -l tests/nvim/check.lua` carrega todos os plugins e falha em qualquer erro.
3. `tests/nvim/startup.sh` mede a abertura contra o limite de 80 ms. Compare com a `dev` alternando as rodadas, nunca com uma medida só.
4. `just lint` (dentro do `nix develop`) roda o stylua e o resto do lint do repo.

O script não confere `desc` em keymap nem `group` em autocmd. Revise isso no diff.
Rode os testes fora do sandbox ou com `-i NONE`. Dentro do sandbox o ShaDa e o cache do `vim.loader` são só de leitura, e o teste mede outra coisa.

## Regras

- **Módulos.** Escreva `local M = {} ... return M`, com tudo `local`. Requerer um módulo não executa nada. Autocmds, keymaps e `vim.pack.add` ficam no `init.lua`, nos arquivos de `plugins/` ou numa função chamada de propósito. Globais só as dos plugins (`Snacks`, `MiniIcons`).
- **Carga.** Chame `vim.loader.enable()` na primeira linha do `init.lua`. Colorscheme e statusline carregam na abertura, e o resto vai para um gatilho. O `require` de plugin opcional fica dentro do callback (`function() require("x").y() end`), nunca no topo do arquivo.
- **Sob demanda com vim.pack.** Dentro do `init.lua`, `load = false` ainda roda o `plugin/` na abertura. Para adiar de verdade, chame `vim.cmd.packadd(nome)` no gatilho e depois o `setup()`. Se o plugin tem `ftplugin/`, dispare o `FileType` de novo no buffer aberto com `nvim_exec_autocmds("FileType", { buf = buf })`. Isso veio de um teste local, não da ajuda. Confirme com o plugin real. O nvim-treesitter não aceita carga sob demanda.
- **APIs.** Use `buf =` em keymap e autocmd, não `buffer =`. Todo keymap leva `desc` no padrão `[Categoria] Ação` (convenção do repo, docs/neovim.md). Todo autocmd fica num `augroup` criado com `clear = true`. Prefira `vim.uv`, `vim.hl`, `vim.diagnostic.jump`, `vim.lsp.config` com `vim.lsp.enable`, `vim.fs.joinpath` e `vim.system`. Bordas vêm do `winborder`, não de cada janela. Em `vim.opt`, passe uma tabela (`vim.opt.x:append({ "a", "b" })`), porque a 0.13 quebrou o encadeamento com operadores `[0.13-dev]`.
- **ui2.** Altura, tempo e pager das mensagens ficam no `messagesopt` (`timeout`, `maxheight`, `pager`). As chaves antigas da `ui2.enable()` dão erro `[0.13-dev]`.
- **Erros.** Use `pcall` só na fronteira, que é plugin opcional, `setup()` de terceiro, arquivo externo ou entrada do usuário. Depois do `pcall`, mostre o erro com `vim.notify(msg, vim.log.levels.ERROR)`. Não use `pcall` para calar erro do nosso código.
- **Tipos.** Anote só a fronteira, que é specs, tabelas de opções e funções de `M`. Classes levam o prefixo `pcastr.`. Use `---@diagnostic disable-next-line` numa linha, nunca no arquivo inteiro.
- **Lua 5.1.** Use `unpack`, não `table.unpack`. Não use `goto`. Use `ffi` só dentro de `if jit`.
- **Formato.** O `just lint` roda o `stylua --config-path config/nvim/.stylua.toml`. O repo não usa selene, porque uma ferramenta nova pede comparação antes (AGENTS.md).
- **Testes.** Teste com `nvim --headless -l`. Não use o plenary, que perdeu a manutenção. Afirme o comportamento:
  - keymap com `vim.fn.maparg(lhs, "n", false, true).desc`, passando o `<leader>` já expandido;
  - comando com `vim.fn.exists(":Cmd") == 2`;
  - tema com `vim.g.colors_name`.

  Em modo headless o `UIEnter` não dispara, então o trabalho adiado para ele fica fora da medida da abertura.

## Recursos

- **`scripts/check-api.sh`** é a fonte única da lista de APIs removidas e deprecadas. Acrescente uma linha `gravidade@regex@substituto` quando achar outra.
- **`references/boas-praticas.md`** traz o porquê e a fonte de cada regra e os pontos ainda em aberto. Consulte antes de mudar uma regra ou quando uma delas parecer errada.
