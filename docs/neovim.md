# Neovim

O Neovim é o nightly 0.13, instalado pelo `bob` (grupo `editor`). A config fica em `home/dot_config/nvim/`.

A regra é usar o que é nativo do Neovim primeiro; plugin só entra quando o nativo não cobre. Hoje são três
assuntos: os temas, a busca (fzf-lua, o mesmo fzf do shell) e o explorer (oil). O resto entra aos poucos.

## Estrutura

```text
home/dot_config/nvim/
  init.lua            líder (Espaço) e a ordem em que os módulos carregam
  lua/config/
    options.lua       opções gerais: números das linhas, swap e backup, menu da linha de comando
    theme.lua         os temas (plugins) e qual deles segue o desktop
    search.lua        busca de arquivos, pastas e texto (fzf-lua)
    explorer.lua      explorer de arquivos (oil)
    keymaps.lua       todos os atalhos com <leader>
    navigation.lua    Ctrl+j/k/l/; entre janelas do Neovim e painéis do tmux
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
| `<leader>ff` | Arquivos do projeto |
| `<leader>fd` | Pastas do projeto; a escolhida abre no explorer |
| `<leader>fz` | Pastas do zoxide (as que você mais usa, de qualquer projeto); abre no explorer |
| `<leader>fg` | Texto no projeto, enquanto digita |
| `<leader>fw` | A palavra do cursor no projeto |
| `<leader>fb` | Arquivos abertos |
| `<leader>fr` | Arquivos recentes |
| `<leader>fh` / `<leader>fk` | Ajuda do Neovim / atalhos |
| `<leader>f.` | Volta à última busca, como estava |
| `-` ou `<leader>e` | Explorer na pasta do arquivo atual |
| `<leader>E` | Explorer na raiz do projeto |
| `jk` | Sai do modo de inserção, como o `Esc` |
| `<leader>R` | Salva tudo e reinicia o Neovim, que lê a config de novo e volta com os mesmos arquivos |
| `Ctrl-j/k/l/;` | Janela à esquerda, abaixo, acima, à direita (as teclas do niri, com Ctrl). Na borda, segue para o painel do tmux ([tmux.md](tmux.md#neovim)) |

`nvim .` (ou `nvim <pasta>`) abre direto no explorer.

## Buscar

A busca é o fzf-lua: o mesmo `fzf` do shell, com prévia ao lado e as cores do tema. A busca é fuzzy (letras fora de
ordem valem: `tmuxconf` acha `home/dot_config/tmux/tmux.conf`). Arquivos e pastas vêm do `fd` e o texto vem do
`rg`: os ocultos aparecem, e o `.git` e o que o git ignora não.

Dentro da busca:

| Tecla | O que faz |
| --- | --- |
| `Enter` | Abre |
| `Ctrl-v` / `Ctrl-s` / `Ctrl-t` | Abre ao lado / embaixo / numa aba |
| `Tab` | Marca vários (o `Enter` abre todos) |
| `Alt-q` | Manda os resultados para o quickfix (`]q` e `[q` andam entre eles) |
| `Alt-h` / `Alt-i` | Mostra ou esconde os ocultos / o que o git ignora |
| `Esc` | Fecha |

Na linha de comando (`:`) e na busca com `/`, um menu fuzzy de sugestões aparece enquanto você digita. `Tab` e
`Shift-Tab` andam no menu.

## Explorer (oil)

O oil abre a pasta como um texto, e você mexe nos arquivos editando as linhas. Nada muda no disco até o `:w`, que
mostra o que vai acontecer quando a mudança é grande.

| Para | Faça |
| --- | --- |
| Abrir | `Enter` (pasta ou arquivo); `gv` / `gh` abre ao lado / embaixo |
| Subir uma pasta | `-` |
| Renomear | Edite o nome (`cw`, `A`...) e `:w` |
| Criar | Uma linha nova com o nome; com `/` no fim é pasta (`a/b/c.txt` cria as pastas no caminho). `:w` |
| Copiar | `yy` no arquivo, vá até a outra pasta, `p` e `:w` |
| Mover | `dd` no arquivo, vá até a outra pasta, `p` e `:w` |
| Apagar | `dd` e `:w`. Vai para a lixeira (`g\` mostra a lixeira) |
| Desfazer antes do `:w` | `u`, como num texto |
| Prévia | `Ctrl-p` |
| Ocultos | `g.` mostra ou esconde (começam à mostra) |
| Abrir fora do Neovim | `gx` |
| Ajuda | `g?` lista todas as teclas |

Vários de uma vez também valem: `Vjj` e `d` ou `y` em várias linhas. Renomear ou mover um arquivo pelo oil avisa o
LSP, que corrige os imports.

## Tema

O Neovim usa o tema do desktop ([temas.md](temas.md)): cada paleta do Noctalia abre o tema oficial equivalente.
Quando o `theme` troca a paleta, os Neovims abertos trocam junto. O `theme.lua` lê a paleta escolhida em
`~/.local/state/noctalia/settings.toml` e vigia esse arquivo; sem escolha (máquina nova), fica o Nord.

O fundo é transparente: aparece o do Ghostty, com a mesma cor e a mesma opacidade (`background-opacity`). Janelas
flutuantes e a barra de status ficam com o fundo do tema.

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

## Números das linhas

A linha do cursor mostra o número dela; as outras mostram a distância até o cursor, para pular com `5j` ou `3k`.

## Arquivos

O Neovim não cria swap (`.swp`) nem backup (`arquivo~`). O histórico fica com o git.

## Reiniciar

`<leader>R` é `:wall` seguido do `:restart` nativo. Ele salva a sessão (janelas e arquivos), fecha, abre um Neovim
novo com a config relida e restaura a sessão. `ZR` faz o mesmo sem salvar os arquivos antes.
