# Shell e terminal

O terminal é o Ghostty e o shell é o fish, com o prompt do starship. Scripts continuam em bash.

## Ghostty abre sempre o fish

O `command` do Ghostty aponta para o fish do home-manager. Assim o terminal abre em fish
mesmo que o seu shell de login seja outro (zsh, por exemplo), sem `chsh`.
Fundo e cores vêm do tema atual: o padrão é **Everforest** com opacidade **0.85** (vidro).
Para mudar: `theme <nome>` e `theme opacity <n>` ([themes.md](themes.md)).

## Atalhos do fish

| Atalho | O que faz |
| --- | --- |
| `Ctrl-K` | escolhe um arquivo da pasta (fzf, com preview) e abre no `nvim` |
| `Ctrl-G` | escolhe uma subpasta (fzf, com preview) e entra nela |
| `Ctrl-F` | aceita a sugestão |
| `Ctrl-R` | histórico (atuin) |
| `Alt-C` | entra numa pasta de qualquer nível (fzf) |

O `Ctrl-G` era o `Ctrl-F` do zsh antigo; o `Ctrl-F` ficou com a sugestão do fish.

## Abreviações

Digite o nome e aperte espaço: o fish expande para o comando.

| Abreviação | Comando |
| --- | --- |
| `l`, `la` | `eza -l` só com permissão e nome (`la` mostra os ocultos) |
| `lt`, `lta` | o mesmo, com a data |
| `lw`, `lwa` | o mesmo, com o tamanho |
| `ll` | `eza -la --git`, pastas primeiro |
| `tree` | `eza --tree --level=2` |
| `g`, `gs`, `lg`, `v` | `git`, `git status -sb`, `lazygit`, `nvim` |
| `ga`, `gaa`, `gb`, `gco`, `gcmsg`, `gd`, `gl`, `gp`, `gst` | `git add`, `add --all`, `branch`, `checkout`, `commit -m`, `diff`, `pull`, `push`, `status` |

`pbcopy` e `pbpaste` são apelidos de `wl-copy` e `wl-paste`.

## O que não veio do zsh antigo

- Powerlevel10k, oh-my-zsh e os plugins de sugestão e de realce: o fish e o starship fazem o mesmo.
- nvm, sdkman e pyenv: use o `uv`, o Nix e o `nix develop` de cada projeto.
- Menu de completar com `h/j/k/l`: o fish usa Tab e as setas.
