# Shell (fish)

A config fica em `home/dot_config/fish/`: `config.fish`, as funções em `functions/` e os plugins do fisher em
`fish_plugins`. Os pacotes ficam no grupo `shell`.

## Atalhos

| Atalho | O que faz |
| --- | --- |
| `Esc` | Modo normal do vi (cursor vermelho). `i` volta para a escrita (verde); `v` seleciona (amarelo) |
| `Ctrl+G` | Vai para uma pasta: as que você mais usa (zoxide) primeiro, depois todas do `~` (fd). O que já está digitado vira a busca |
| `Ctrl+R` | Busca no histórico (fzf) |
| `Ctrl+T` | Cola o caminho de um arquivo (fzf) |
| `Ctrl+O` ou `mf <busca>` | Busca nos manuais por nome ou assunto, com o manual ao lado; `Enter` abre no Neovim |
| `z <parte do nome>` | Entra direto na pasta mais usada que combina (zoxide) |
| `t` | Abre ou volta para uma sessão do tmux, pela lista do sesh ([tmux.md](tmux.md)) |

O cursor é sempre um bloco. As cores vêm de `devenv_cursor_insert`, `devenv_cursor_normal` e
`devenv_cursor_visual` (hex sem `#`). O padrão é o Nord, até o comando `theme` trocar ([temas.md](temas.md)).

## Manuais

O `man` abre no Neovim. Dentro dele: `/palavra` busca e `n` vai para a próxima, `gO` mostra as seções, `K` sobre um
nome abre aquele manual, `Ctrl+O` volta e `q` sai. Para exemplos curtos, `tldr <comando>` (o hook do grupo `shell`
atualiza as páginas a cada `just sync`).

## Abreviações

Viram o comando inteiro quando você aperta espaço, então o histórico guarda o comando de verdade.

| Abreviação | Vira |
| --- | --- |
| `g`, `gs`, `ga`, `gc`, `gca` | `git`, `git status -sb`, `git add`, `git commit`, `git commit --amend` |
| `gp`, `gl`, `gd`, `gds`, `gsw`, `glg` | push, pull, diff, diff --staged, switch, log em grafo |
| `lg` | `lazygit` |
| `v` | `nvim` |
| `j`, `dv` | `just`; `just` do devenv de qualquer pasta (`dv sync`, `dv apply`) |
| `..`, `...`, `....` | `cd ../`, `cd ../../`, e assim por diante |
| `!!` | o último comando (ex.: `sudo !!`) |

`ns` guarda as notas de `~/notas` no GitHub (commit e push), de qualquer pasta.

`ls`, `ll`, `la` e `lt` são funções, não abreviações: a linha continua mostrando só `ls`, e por baixo roda o
`eza` (lista, longa com git, com ocultos, em árvore).

## Prompt

O tide no estilo Lean, em duas linhas: pasta e branch em cima, e à direita o status do último comando, o tempo
dele quando passa de 3 s e as versões da linguagem do projeto (Python, Node, Rust, Go, Elixir...). Usa as 16 cores
do terminal, então segue o tema. O prompt anterior encolhe depois de cada comando (transient). O hook do fisher no
grupo `shell` reinstala o tide e refaz essa config a cada `just sync`.

## Desempenho

O fish interativo abre em uns 12 ms nesta máquina, contra 2 ms sem config nenhuma. Desses 10 ms, o `config.fish`
custa 1,4 ms; o resto é o tide e a carga interativa do próprio fish (medido com `fish --profile-startup`).

- A saída do `zoxide init` e do `fzf --fish` fica em cache em `~/.cache/fish/` e só é gerada de novo quando o
  programa é atualizado.
- O mise entra pelos shims, não pelo `mise activate`, que custava uns 15 ms a cada prompt. A versão continua
  sendo a do projeto; só o `[env]` do `mise.toml` fica de fora.
- As funções ficam em `functions/` e só carregam no primeiro uso.
