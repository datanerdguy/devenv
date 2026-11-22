# 0012. Desktop e teclado no CachyOS

Data: 2026-11-22 · Status: aceita. Substitui o ADR 0004; o ADR 0008 (atalhos com Alt) continua.

## Contexto

O CachyOS instala o niri e o Noctalia pelo meta-pacote `cachyos-niri-noctalia`, que copia uma config em
`~/.config/niri/cfg/`. Essa config não fica no repo e traz coisas que não usamos (alacritty, steam). A máquina tem
um ultrawide e a tela do notebook, as duas saindo pela placa Intel. O Corne já faz no firmware o que o kanata fazia
no teclado do notebook.

## Decisão

- **Pacotes explícitos** no grupo `desktop`, sem o meta-pacote: niri, Noctalia, portais, keyring, cursor, fontes,
  Zen e as ferramentas dos atalhos.
- **Config nossa do niri** em três arquivos ligados ao repo (`config.kdl`, `binds.kdl`, `rules.kdl`), com o
  visual do CachyOS (espaço de 16 px, cantos de 20 px, blur) e os atalhos do ADR 0008.
- **Monitores pelo modelo**, num arquivo só. O niri ignora o que não está ligado, então não há arquivo por máquina.
- **Capturas pelo niri**; anotação pelo satty (`Super+Print`), no lugar do flameshot. Desenho na tela pelo
  wayscriber (`Alt+Shift+D`).
- **Notas em Markdown** em `~/notas`, um repo git privado à parte. O `Super+n` só abre a nota do dia; os plugins
  entram na área do Neovim.
- **Noctalia** com config no repo; os ajustes da tela ficam no estado dele e `just noctalia-diff` os mostra.
- **Teclado:** Vial pelo `vial-appimage`, que já traz a regra udev. Sem kanata. Layout `us intl` no niri.

## Alternativas

- **Manter a config do CachyOS:** funciona, mas fica fora do repo e mistura o que não usamos.
- **Um arquivo de monitores por máquina:** mais peças, sem ganho, porque o niri casa o monitor pelo modelo.
- **Org mode (nvim-orgmode):** melhor para agenda e tarefas com data, mas só abre no Neovim ou no Emacs.
- **kanata no notebook:** o Lucas quase só usa o Corne; volta se fizer falta.
- **Tirar o blur:** o log do niri mostrou atrasos de até 357 ms no teclado e no mouse, e o blur na Intel é o
  suspeito. O Lucas preferiu manter e olhar o log de novo depois.

## Consequências

- Sem kanata, não há arquivo de sistema (`/etc`) para cuidar: a única regra udev vem do próprio pacote do Vial.
- O `cachyos-alacritty-config` vira órfão quando o meta-pacote sai.
- O `~/.config/niri/cfg/` antigo deixa de ser lido e pode ser apagado.
