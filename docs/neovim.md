# Neovim

O Neovim é o nightly 0.13, instalado pelo `bob` (grupo `editor`). A config fica em `home/dot_config/nvim/`.

A regra é usar o que é nativo do Neovim primeiro; plugin só entra quando o nativo não cobre, como os temas. Buscar arquivos, buscar texto e a árvore de pastas vêm
das receitas da ajuda do próprio Neovim (`:help cmdline-autocompletion` e `:help fuzzy-file-picker`). Por
enquanto a config tem só isso; o resto entra aos poucos.

## Estrutura

```text
home/dot_config/nvim/
  init.lua            líder (Espaço) e a ordem em que os módulos carregam
  lua/config/
    options.lua       opções gerais: swap e backup, menu da linha de comando, grep, netrw
    search.lua        :find, :Recent e o menu fuzzy enquanto digita
    keymaps.lua       todos os atalhos com <leader>
    navigation.lua    Ctrl+j/k/l/; entre janelas do Neovim e painéis do tmux
    theme.lua         os temas (plugins) e qual deles segue o desktop
  nvim-pack-lock.json versões dos plugins, gravada pelo vim.pack
```

Assunto novo ganha um arquivo em `lua/config/` e uma linha `require` no `init.lua`. Para o que o Neovim já
procura sozinho, use as pastas dele, criadas quando o primeiro arquivo entrar:

- `lsp/<servidor>.lua`: config de um LSP, lida pelo `vim.lsp.config`;
- `after/ftplugin/<linguagem>.lua`: ajustes por tipo de arquivo (indentação, por exemplo).

O chezmoi liga cada arquivo, inclusive os das subpastas. Arquivo novo só aparece em `~/.config/nvim` depois do
`just apply`; editar um que já existe vale na hora (`<leader>R` para o Neovim ler de novo).

## Atalhos

O `<leader>` é o **Espaço**.

| Tecla | O que faz |
| --- | --- |
| `<leader>ff` | `:find`: busca arquivos do projeto |
| `<leader>fg` | `:grep`: busca texto no projeto; o resultado abre no quickfix |
| `<leader>fb` | `:b`: arquivos abertos |
| `<leader>fr` | `:Recent`: arquivos abertos antes |
| `<leader>e` | Árvore de pastas (netrw) na pasta do arquivo atual |
| `<leader>R` | Salva tudo e reinicia o Neovim, que lê a config de novo e volta com os mesmos arquivos |
| `Ctrl-j/k/l/;` | Janela à esquerda, abaixo, acima, à direita (as teclas do niri, com Ctrl). Na borda, segue para o painel do tmux ([tmux.md](tmux.md#neovim)) |

`nvim .` (ou `nvim <pasta>`) abre direto na árvore.

## Buscar

Em `:find`, `:b` e `:Recent`, um menu de sugestões aparece enquanto você digita, com busca fuzzy (letras fora
de ordem valem: `tmuxconf` acha `home/dot_config/tmux/tmux.conf`). `Tab` e `Shift-Tab` andam no menu, e o
`Enter` abre a escolhida, ou a primeira se você não escolher nenhuma. O mesmo menu aparece no `:` e na busca com `/`.

O `:find` lista os arquivos com o `fd`: os ocultos aparecem, e o `.git` e o que o git ignora não.

O `:grep` usa o `rg`, com as mesmas regras. Os resultados vão para o quickfix: `Enter` abre o resultado, `]q` e
`[q` andam entre eles, e `:cclose` fecha a lista. Texto com espaço vai entre aspas: `:grep "duas palavras"`.

## Árvore (netrw)

`Enter` abre, `-` sobe uma pasta, `%` cria arquivo, `d` cria pasta, `D` apaga, `R` renomeia e `gh` mostra os
ocultos. `:help netrw-quickmap` lista todas as teclas.

## Tema

O Neovim usa o tema do desktop ([temas.md](temas.md)): cada paleta do Noctalia abre o tema oficial equivalente.
Quando o `theme` troca a paleta, os Neovims abertos trocam junto. O `theme.lua` lê a paleta escolhida em
`~/.local/state/noctalia/settings.toml` e vigia esse arquivo; sem escolha (máquina nova), fica o Nord.

| Paleta | Plugin |
| --- | --- |
| `catppuccin-*` | `catppuccin/nvim` |
| `kanagawa-*` | `rebelot/kanagawa.nvim` |
| `rose-pine`, `rose-pine-moon` | `rose-pine/neovim` |
| `everforest-*` | `sainnhe/everforest` (o contraste vai em `g:everforest_background`) |
| `nord` | `gbprod/nord.nvim` (o oficial é de Vim e não cobre treesitter nem LSP) |
| `dracula` | `Mofiqul/dracula.nvim` (pelo mesmo motivo) |

Variante nova em `temas/gerar.py` precisa de uma linha na tabela `themes` do `theme.lua`.

## Plugins

O gerenciador é o nativo, `vim.pack`. Na primeira vez, ele baixa os plugins sozinho. As versões ficam em
`nvim-pack-lock.json`, no repo, então toda máquina instala as mesmas.

| Comando | O que faz |
| --- | --- |
| `:packupdate` | Mostra as atualizações; `:write` confirma, `:quit` descarta. Depois, commit do `nvim-pack-lock.json` |
| `:packdel <nome>` | Apaga um plugin que saiu da config |

## Arquivos

O Neovim não cria swap (`.swp`) nem backup (`arquivo~`). O histórico fica com o git.

## Reiniciar

`<leader>R` é `:wall` seguido do `:restart` nativo. Ele salva a sessão (janelas e arquivos), fecha, abre um Neovim
novo com a config relida e restaura a sessão. `ZR` faz o mesmo sem salvar os arquivos antes.
