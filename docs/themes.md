# Temas

Um comando troca o tema do desktop inteiro de uma vez. O porquê está no [ADR 0013](adr/0013-themes-via-noctalia.md).

## Trocar

| Como | O que faz |
| --- | --- |
| `Alt+Shift+t` | Abre a lista das variantes numa janela flutuante, com a amostra das cores ao lado |
| `theme` | A mesma lista, no terminal |
| `theme catppuccin-mocha` | Troca direto (o `Tab` completa os nomes) |

A troca vale na hora, também nos apps abertos. A escolha fica no estado do Noctalia, então sobrevive ao login e não
mexe no repo. Numa máquina nova, o padrão é o Nord.

## Variantes

| Tema | Variantes |
| --- | --- |
| Nord | `nord` |
| Everforest | `everforest-hard`, `everforest-medium`, `everforest-soft` |
| Rosé Pine | `rose-pine`, `rose-pine-moon` |
| Catppuccin | `catppuccin-mocha`, `catppuccin-macchiato`, `catppuccin-frappe` |
| Dracula | `dracula` |
| Kanagawa | `kanagawa-wave`, `kanagawa-dragon` |

Só as variantes escuras, com as cores oficiais.

## Quem segue o tema

O Noctalia guarda a paleta e, a cada troca, regenera a config de cada app a partir de um modelo:

| App | Modelo |
| --- | --- |
| Noctalia (barra, launcher, notificações, bloqueio) | a própria paleta |
| Ghostty | pronto do Noctalia (`~/.config/ghostty/themes/noctalia`) |
| niri (bordas e foco das janelas) | pronto do Noctalia (`~/.config/niri/noctalia.kdl`) |
| GTK 3 e 4, Qt | prontos do Noctalia |
| btop | pronto do Noctalia |
| Zen, yazi | da comunidade do Noctalia |
| lazygit | nosso, em `home/dot_config/noctalia/templates/lazygit.yml` |
| Cursor do fish e do Neovim (verde escreve, vermelho normal, amarelo visual) | nosso, em `home/dot_config/noctalia/templates/fish-cursor.fish` |
| Neovim | o tema oficial de cada paleta, pelo `vim.pack` (veja [neovim.md](neovim.md#tema)) |
| tmux (barra, bordas, popups) | nosso, em `home/dot_config/noctalia/templates/tmux.conf`; recarrega o tmux aberto |
| fzf, bat, eza, prompt (tide), delta | sem modelo: usam as 16 cores do terminal, então seguem o Ghostty |

O Zen só pega as cores novas depois de reaberto.

## Acrescentar uma variante

1. Confira o nome do tema no Ghostty: `ghostty +list-themes`.
2. Acrescente a linha em `VARIANTS`, em `themes/generate.py`. Se for uma família nova, escolha as cores de destaque em
   `ACCENTS`.
3. Rode `python3 themes/generate.py`. Ele escreve as paletas em `home/dot_config/noctalia/palettes/`.
4. `just apply` liga a paleta nova, e o `just lint` confere que as paletas batem com o gerador.

As cores do terminal vêm do arquivo oficial do Ghostty. As da interface saem delas: fundo, texto e três cores de
destaque por família (o ciano no Nord, o verde no Everforest, a íris no Rosé Pine e o azul do ANSI nos outros).

## Papéis de parede

O papel de parede não muda com o tema. A pasta `wallpapers/` do repo fica ligada em `~/Pictures/Wallpapers`, que é
a pasta do seletor do Noctalia. Coloque as imagens lá e escolha pelo Noctalia.
