# Neovim

Neovim nightly (0.13) instalado pelo [bob](https://github.com/MordechaiHadad/bob), com config em Lua escrita do zero em [`config/nvim`](../config/nvim). O módulo [`modules/nvim`](../modules/nvim/default.nix) liga a pasta em `~/.config/nvim` como link direto: editar o repo muda o editor na hora, sem `just switch`.

Princípios:

- **Leve.** Só o tema, ícones, statusline e o snacks carregam na abertura; todo o resto carrega quando é usado (evento, tipo de arquivo, comando ou tecla). O CI falha se a abertura passar de 80 ms (mediana de 7 execuções; local fica em torno de 25 ms).
- **Nativo primeiro.** `vim.pack` para plugins, `vim.lsp.config`/`vim.lsp.enable` para LSP, sem lazy.nvim nem mason-lspconfig.
- **Reproduzível.** As versões dos plugins ficam em [`nvim-pack-lock.json`](../config/nvim/nvim-pack-lock.json), versionado no git.

## Estrutura

```text
config/nvim/
  init.lua                 ordem de carga
  nvim-pack-lock.json      versões travadas dos plugins (gerado pelo vim.pack)
  lua/pcastr/
    options.lua            opções do editor
    keymaps.lua            atalhos gerais
    data.lua               dados: harlequin, tabiew e SQL no DuckDB (sem plugin)
    autocmds.lua           automações (destaque ao copiar, voltar à última posição...)
    pack.lua               carga sob demanda + gerenciador :Pack
    lsp.lua                servidores LSP e diagnósticos
    theme.lua              colorscheme do tema atual (segue o comando `theme`)
    plugins/
      ui.lua               mini, snacks, which-key
      editor.lua           treesitter, gitsigns, smart-splits
      coding.lua           blink.cmp, tiny-inline-diagnostic, conform, nvim-lint, mason
      ai.lua               sidekick (qualquer CLI de agente), claudecode
      notebooks.lua        molten + image.nvim, marimo
      notes.lua            obsidian.nvim (notas no cofre do Obsidian)
      debug.lua            nvim-dap, dap-view, dap-python
```

## Plugins

| Plugin | Para que | Quando carrega |
| --- | --- | --- |
| everforest, rose-pine, catppuccin, dracula.nvim | temas; só o escolhido pelo `theme` carrega ([themes.md](themes.md)) | abertura |
| mini.nvim | ícones, statusline, textobjects, surround, pares | abertura (ícones e statusline); o resto no primeiro arquivo |
| snacks.nvim | picker, explorer, dashboard, terminal, lazygit, notificações, zen | abertura (cada módulo só roda quando chamado) |
| which-key.nvim | mostra as teclas depois do `<leader>` | depois da interface abrir |
| nvim-treesitter | realce, indentação e dobras | primeiro arquivo |
| nvim-treesitter-context | fixa no topo a função ou classe atual | primeiro arquivo |
| nvim-ts-autotag | fecha e renomeia a tag par (HTML, HEEx, templates) | arquivo HTML ou template |
| gitsigns.nvim | marcas e ações de git por trecho | primeiro arquivo |
| smart-splits.nvim | navegar entre janelas do Neovim e painéis do tmux | tecla |
| nvim-lspconfig | configurações prontas dos servidores (só dados) | abertura |
| mason.nvim | instalador de LSPs e ferramentas | `:Mason` |
| blink.cmp | completion | modo de inserção, linha de comando ou arquivo |
| tiny-inline-diagnostic.nvim | diagnóstico inline | primeiro diagnóstico |
| conform.nvim | formatar ao salvar | ao salvar |
| nvim-lint | linters extras | primeiro arquivo |
| sidekick.nvim | terminal de agentes (Claude, Codex, Gemini, opencode) | tecla |
| claudecode.nvim | integração de IDE do Claude Code | tecla ou comando |
| molten-nvim + image.nvim | rodar células Jupyter no buffer | tecla |
| obsidian.nvim | notas no cofre do Obsidian (links, nota do dia, modelos) | tecla, `:Obsidian` ou nota do cofre |
| nvim-dap + dap-view + dap-python | debug | tecla |

## Gerenciador de plugins (:Pack)

O `vim.pack` instala e atualiza, mas não mostra o estado. O [`pack.lua`](../config/nvim/lua/pcastr/pack.lua) acrescenta isso:

| Comando | O que faz |
| --- | --- |
| `:Pack` (`<leader>pp`) | Lista os plugins: estado, versão, gatilho de carga e tempo de carga. A prévia mostra os últimos commits |
| `:Pack!` (`<leader>pc`) | O mesmo, buscando atualizações na rede (mostra `↑` com a nova versão) |
| `:PackUpdate [nomes]` (`<leader>pu`) | Atualiza; abre a revisão do `vim.pack` antes de aplicar (`:w` confirma, `:q` cancela) |
| `:PackRestore [nomes]` | Volta os plugins às versões do `nvim-pack-lock.json` (sem rede) |
| `:PackClean` | Remove plugins instalados que saíram da config |
| `:PackStatus` (`<leader>ps`) | Resumo: quantos plugins, quantos carregados e o tempo total |

Dentro do `:Pack`: `Alt-u` atualiza os selecionados, `Alt-U` atualiza todos, `Alt-x` remove, `Alt-c` busca atualizações.

Estados: `●` carregado, `○` sob demanda (ainda não usado), `✗` instalado mas fora da config.

Depois de atualizar, faça commit do `nvim-pack-lock.json`. Para voltar uma versão: `git checkout -- config/nvim/nvim-pack-lock.json` e `:PackRestore`.

Vindo de outra config que também usava o `vim.pack`, os plugins dela ficam em `~/.local/share/nvim/site/pack/core`,
e o devenv usa o que achar ali, mesmo de outra versão (ex.: `blink.cmp v2 requires "saghen/blink.lib"`). Mova a
pasta para **fora** de `site/pack` (o Neovim lê todas as pastas ali dentro) e abra o Neovim: ele instala tudo pelo lockfile.

### Acrescentar um plugin

Escolha o arquivo em `plugins/` pelo assunto e acrescente uma entrada em `pack.add`:

```lua
pack.add({
  {
    src = gh("dono/plugin.nvim"),
    version = vim.version.range("1.*"), -- opcional: tag, branch ou faixa semver
    event = "BufReadPost",              -- carrega no evento
    -- ft = { "python" },               -- ou no tipo de arquivo
    -- cmd = { "Comando" },             -- ou no comando
    -- keys = { { "<leader>x", fn, desc = "..." } }, -- ou na tecla
    deps = { "outro-plugin" },          -- carrega antes deste
    build = function(path) end,         -- roda depois de instalar ou atualizar
    config = function() require("plugin").setup({}) end,
  },
})
```

Sem `event`, `ft`, `cmd` ou `keys` o plugin carrega na abertura; prefira sempre um gatilho. `keys = {}` faz o plugin carregar só como dependência de outro. Rode `just nvim-test` para conferir que tudo carrega e que a abertura continua rápida.

## LSP

Os servidores estão em [`lsp.lua`](../config/nvim/lua/pcastr/lsp.lua) e ligam sozinhos quando o executável existe. Três jeitos de instalar um servidor, do mais rápido ao mais reproduzível:

1. `:Mason` e instale (fica em `~/.local/share/nvim/mason`). Bom para experimentar.
2. No `flake.nix` do projeto, ativado pelo direnv. Bom para o que é do projeto (ex.: versão do Go).
3. Em [`modules/nvim/default.nix`](../modules/nvim/default.nix), para toda máquina.

O que o Nix ou o devShell instalam tem prioridade sobre o Mason. Para um servidor novo, acrescente o nome (do nvim-lspconfig, `:help lspconfig-all`) em `servers`.

Já vêm pelo Nix: lua_ls, basedpyright, ruff, gopls, nixd, marksman, taplo, yamlls, html/css/json, bashls, dockerls, tailwindcss, ts_ls, mais stylua, gofumpt, goimports, nixfmt, shfmt, shellcheck, hadolint e actionlint. Rust usa o `rust-analyzer` do rustup (`rustup component add rust-analyzer`), para bater com o toolchain do projeto. Elixir (`expert`) vem pelo `:Mason`.

| Comando | O que faz |
| --- | --- |
| `:LspServers` | Lista os servidores configurados e quais estão instalados |
| `<leader>cl` | `:checkhealth vim.lsp` (servidores ligados no buffer) |
| `<leader>cR` | Reinicia o LSP |
| `:ConformInfo` | Formatadores do arquivo |

Diagnósticos: o `virtual_text` nativo fica desligado e quem mostra inline é o tiny-inline-diagnostic, então nada se sobrepõe. Sinais na coluna e o float (`<leader>cd`) continuam nativos.

## Atalhos

O `<leader>` é **Espaço**. Aperte Espaço e espere para o which-key mostrar as opções; `<leader>?` mostra os atalhos do buffer atual.

### Geral

| Tecla | Ação |
| --- | --- |
| `<leader>w` / `<leader>q` / `<leader>Q` | Salvar / fechar janela / sair |
| `<leader>R` | Reiniciar o Neovim mantendo a sessão |
| `jk` | Sair do modo de inserção |
| `Esc` | Limpar destaque da busca |
| `J` / `K` (no modo visual) | Mover a seleção |
| `<leader>-` / `<leader>\|` / `<leader>=` | Dividir abaixo / à direita / igualar |
| `Ctrl-h/j/k/l` | Ir para a janela (ou painel do tmux) ao lado |
| `Ctrl-setas` | Redimensionar janela |
| `Shift-h` / `Shift-l` / `<leader>bb` | Buffer anterior / próximo / último |
| `<leader>bd` / `<leader>bo` | Fechar buffer / fechar os outros |
| `]q` / `[q` | Próximo / anterior no quickfix |
| `Ctrl-/` | Terminal flutuante |
| `Esc Esc` | Sair do modo terminal |
| `<leader>.` | Rascunho |
| `<leader>yp` / `<leader>yP` / `<leader>yn` | Copiar caminho relativo / absoluto / nome do arquivo |
| `<leader>yl` | Copiar `caminho:linha` (na seleção, `caminho:início-fim`), para colar num agente |

### Buscar (`<leader>f`) e explorer

Todas as buscas mostram arquivos ocultos. No picker, `Alt-h` alterna ocultos e `Alt-i` alterna os ignorados pelo git.

| Tecla | Ação |
| --- | --- |
| `<leader><space>` | Busca inteligente de arquivos |
| `<leader>/` ou `<leader>fg` | Texto no projeto |
| `<leader>ff` | Arquivos |
| `<leader>fw` | Palavra sob o cursor (ou seleção) |
| `<leader>fb` / `<leader>fr` | Buffers / recentes |
| `<leader>fh` / `<leader>fk` | Ajuda / atalhos |
| `<leader>fc` / `<leader>fp` | Arquivos da config / projetos |
| `<leader>fs` / `<leader>fS` | Símbolos do arquivo / do projeto |
| `<leader>f.` | Reabrir a última busca |
| `<leader>e` / `<leader>E` | Explorer (alterna) / explorer no arquivo atual |

No explorer: `Enter` abre, `a` cria (termine com `/` para pasta), `d` apaga, `r` renomeia, `c` copia, `m` move, `H` alterna ocultos, `?` mostra todas as teclas.

### Código (`<leader>c`) e LSP

| Tecla | Ação |
| --- | --- |
| `gd` / `gD` / `gy` / `gr` | Definição / declaração / tipo / referências |
| `K` | Documentação |
| `]]` / `[[` | Próxima / anterior ocorrência da palavra |
| `<leader>ca` | Ações de código |
| `<leader>cr` | Renomear |
| `<leader>cf` | Formatar |
| `<leader>cd` | Diagnóstico da linha |
| `]d` / `[d` | Próximo / anterior diagnóstico (nativo) |

Completion: `Tab` aceita (o primeiro item já vem marcado) e pula para o próximo campo do snippet, `Ctrl-n`/`Ctrl-p` escolhem, `Ctrl-Space` abre, `Ctrl-e` fecha.

### Diagnósticos e listas (`<leader>x`)

| Tecla | Ação |
| --- | --- |
| `<leader>xx` / `<leader>xb` | Diagnósticos do projeto / do arquivo |
| `<leader>xq` | Quickfix |
| `<leader>xt` | TODO, FIXME, HACK, NOTE |

### Git (`<leader>g`, `<leader>h`)

| Tecla | Ação |
| --- | --- |
| `<leader>gg` | Lazygit |
| `<leader>gs` / `<leader>gl` / `<leader>gf` | Alterados / log / log do arquivo |
| `<leader>gB` | Abrir no GitHub |
| `]h` / `[h` | Próximo / anterior hunk |
| `<leader>hs` / `<leader>hr` / `<leader>hS` | Stage / desfazer hunk / stage do arquivo |
| `<leader>hp` / `<leader>hb` / `<leader>hd` | Ver hunk / blame / diff |
| `ih` | Hunk como textobject (ex.: `dih`) |

### IA e agentes (`<leader>a`)

| Tecla | Ação |
| --- | --- |
| `<leader>aa` | Abrir/fechar o terminal do agente |
| `<leader>as` | Escolher o CLI (Claude, Codex, Gemini, opencode...) |
| `<leader>at` / `<leader>af` / `<leader>av` | Mandar o trecho / arquivo / seleção |
| `<leader>ap` | Prompts prontos |
| `<leader>ad` | Encerrar a sessão |
| `Ctrl-.` | Focar o agente |
| `<leader>ac` | Claude Code (integração de IDE) |
| `<leader>ab` / `<leader>ae` | Mandar arquivo / seleção ao Claude Code |
| `<leader>ay` / `<leader>an` | Aceitar / recusar diff proposto |
| `<leader>am` | Escolher o modelo |

As sessões do sidekick rodam no tmux, então continuam vivas se o Neovim fechar.

### Notebooks (`<leader>n`)

| Tecla | Ação |
| --- | --- |
| `<leader>ni` | Iniciar kernel (molten) |
| `<leader>nl` / `<leader>nv` / `<leader>ne` | Rodar linha / seleção / operador (ex.: `<leader>neip`) |
| `<leader>nr` | Rodar a célula de novo |
| `<leader>no` / `<leader>nh` | Abrir / esconder a saída |
| `<leader>nd` / `<leader>nI` | Apagar célula / interromper kernel |
| `<leader>nm` / `<leader>nM` | marimo: editar o notebook / rodar como app |

O molten usa o kernel do projeto: tenha `ipykernel` nas dependências de dev (`uv add --dev ipykernel`) e registre com `uv run python -m ipykernel install --user --name <projeto>`. Imagens aparecem no Ghostty (protocolo do kitty). O marimo roda com `uvx`, sem instalar nada.

### Notas (`<leader>z`)

Mesmo cofre do app Obsidian (`~/notes`, ou `$DEVENV_NOTES`). Detalhes em [apps.md](apps.md#notas-obsidian--neovim).

| Tecla | Ação |
| --- | --- |
| `<leader>zn` | Nova nota (vai para `zettel/`, com ID de data e hora) |
| `<leader>zz` / `<leader>zs` | Abrir nota pelo nome / buscar no texto |
| `<leader>zd` / `<leader>zy` | Nota de hoje / de ontem (`diario/`) |
| `<leader>zt` | Nova nota a partir de um modelo (zettel, conceito, diário) |
| `<leader>zb` / `<leader>zl` / `<leader>z#` | Quem aponta para a nota / links dela / tags |
| `<leader>zr` | Renomear, atualizando os links |
| `<leader>zp` | Colar imagem do clipboard (vai para `anexos/`) |
| `<leader>ze` / `<leader>zk` | Seleção vira nota nova / vira link para nota nova |
| `<leader>zo` | Abrir a nota no app Obsidian |

Dentro de uma nota: `Enter` segue o link, marca a caixa ou abre as notas da tag; `]l` / `[l` pulam entre links; `[[` completa o nome de outra nota e `#` as tags.

### Debug (`<leader>d`)

| Tecla | Ação |
| --- | --- |
| `<leader>db` | Breakpoint |
| `<leader>dc` | Iniciar / continuar |
| `<leader>di` / `<leader>do` / `<leader>dO` | Entrar / pular / sair |
| `<leader>dr` / `<leader>du` | REPL / painel |
| `<leader>dt` | Encerrar |

Python usa o ambiente do projeto via uv (`debugpy` nas dependências de dev).

### Dados (`<leader>D`)

Sem plugin de banco: o Neovim abre as ferramentas do terminal numa janela flutuante e roda SQL no DuckDB. Fluxos em [data.md](data.md).

| Tecla | Ação |
| --- | --- |
| `<leader>Dh` | Harlequin (IDE de SQL) na raiz do projeto |
| `<leader>Dt` | Tabiew no arquivo atual (CSV, Parquet, Excel…) ou escolher um |
| `<leader>Dr` | Rodar o arquivo `.sql` (ou a seleção) no DuckDB; o resultado abre num split abaixo |
| `<leader>Db` | Escolher o banco do DuckDB do buffer (vazio = em memória) |

### Alternar (`<leader>u`)

| Tecla | Ação |
| --- | --- |
| `<leader>uw` / `<leader>us` / `<leader>ur` | Quebra de linha / corretor / número relativo |
| `<leader>uh` / `<leader>ud` | Inlay hints / diagnósticos |
| `<leader>uf` | Formatar ao salvar |
| `<leader>uz` / `<leader>un` | Modo zen / histórico de notificações |
| `<leader>uc` / `[C` | Contexto no topo (função atual) / ir até ele |

O corretor aceita as palavras de [`config/nvim/spell/tech.utf-8.add`](../config/nvim/spell/tech.utf-8.add): `zg` acrescenta a palavra sob o cursor e o arquivo vai para o git.

## Versão do Neovim

```bash
bob use nightly     # padrão
bob use stable      # se a nightly quebrar algo
bob update --all    # ou: just nvim-update (atualiza também os plugins)
bob rollback        # volta a nightly anterior
```

A versão instalada no primeiro switch é `devenv.nvim.version` no host.

## Testes

`just nvim-test` (e o CI, nos containers Fedora e Ubuntu):

- [`tests/nvim/check.lua`](../tests/nvim/check.lua) instala os plugins pelo lockfile, carrega todos, abre arquivos de várias linguagens e falha em qualquer erro.
- [`tests/nvim/startup.sh`](../tests/nvim/startup.sh) mede a abertura e falha acima do limite (`tests/nvim/startup.sh 50` para outro limite).
