# 0005. Temas: uma paleta por tema, arquivos gerados pelo Nix, troca na hora pelo `theme`

Data: 2026-10-23 · Status: aceita

## Contexto

Os quatro temas (Everforest, Rosé Pine, Catppuccin, Dracula) precisam mudar tudo de uma vez, no estilo do
Omarchy, com papel de parede combinando e transparência ajustável. A troca tem de ser rápida (sem rebuild),
funcionar também fora do niri (sessão i3) e ser testável no CI. O Noctalia v5 já é um motor de temas
(paletas, modelos de arquivo, IPC), mas não cobre o Neovim e o tmux do jeito que queremos, e o modelo dele
para o Ghostty edita a config, que aqui é do home-manager.

Opções avaliadas em detalhe: [documento da fase 5](https://claude.ai/artifact/7Z8cEedgRKJMNuG5mmkLJS).

## Decisão

- **Uma paleta por tema** (`themes/<tema>/palette.json`), no formato de paleta do Noctalia: cores da interface
  e as 16 do terminal. É a única fonte de cores.
- **O Nix gera os arquivos de cada tema no build** (Ghostty, tmux, niri, papéis de parede baixados com hash fixo)
  e instala os quatro em `~/.local/share/devenv/themes`.
- **O comando `theme`** troca um link (`~/.local/state/devenv/theme/current`), gera os arquivos que dependem da
  opacidade e avisa os apps abertos: sinais para Ghostty e Neovim, `source-file` no tmux, `noctalia msg` no
  Noctalia. `Super+T` abre a lista com prévia.
- **Neovim** usa o colorscheme oficial de cada tema (só o escolhido carrega); **ferramentas de terminal** usam as
  16 cores do terminal, sem arquivo próprio.
- **Só variantes escuras** por enquanto. **Um ajuste de opacidade** vale para o Ghostty e os painéis do Noctalia.
- **CI**: `nix flake check` gera os quatro temas e valida com `ghostty +validate-config`, `niri validate`,
  `noctalia config validate` e o tmux; o teste do Neovim aplica os quatro colorschemes.

## Alternativas consideradas

- **Só o Noctalia (modelos dele):** nada a escrever, mas não roda no i3, o modelo do Ghostty edita a config e o
  Neovim e o tmux ficariam com cores genéricas.
- **Stylix:** cobre muitos apps, mas cada troca é um rebuild e ele disputa as mesmas configs com o Noctalia.
- **tinty (base16):** leve, mas seria um segundo motor ao lado do Noctalia, e o base16 perde detalhes dos temas oficiais.
- **Papéis de parede no repo:** funcionam offline, mas deixam o repo pesado para sempre (o histórico guarda tudo).

## Consequências

- Mudar uma cor é editar o `palette.json` e rodar `just switch`.
- Um tema novo precisa de três coisas: paleta, papéis de parede e o colorscheme do Neovim (passo a passo em `docs/themes.md`).
- GTK e Qt usam os modelos do próprio Noctalia (CSS do GTK 3/4 e paleta do qt6ct), então só mudam com o Noctalia
  rodando (niri ou sway). btop, zathura, Flameshot, Obsidian e as cores do sway e do i3 saem da mesma paleta,
  pelo `theme`.
- O Zen não troca sozinho: precisaria do Pywalfox e de um programa auxiliar, que não funcionam bem com o Flatpak.
