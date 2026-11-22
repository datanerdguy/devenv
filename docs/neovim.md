# Neovim

O Neovim é o nightly 0.13, instalado pelo `bob` (grupo `editor`). A config fica em `home/dot_config/nvim/`.

A regra é usar o que é nativo do Neovim e não ter plugins. Buscar arquivos, buscar texto e a árvore de pastas vêm
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

## Arquivos

O Neovim não cria swap (`.swp`) nem backup (`arquivo~`). O histórico fica com o git.

## Reiniciar

`<leader>R` é `:wall` seguido do `:restart` nativo. Ele salva a sessão (janelas e arquivos), fecha, abre um Neovim
novo com a config relida e restaura a sessão. `ZR` faz o mesmo sem salvar os arquivos antes.
