# Desktop e teclado

O compositor é o **niri**: as janelas ficam em colunas que rolam na horizontal. Em cima dele roda o
**Noctalia**, com barra, launcher, notificações e tela de bloqueio.

## Onde fica cada coisa

| No repo | Na máquina |
| --- | --- |
| `home/dot_config/niri/config.kdl` (entrada, monitores, visual) | `~/.config/niri/config.kdl` (link) |
| `home/dot_config/niri/binds.kdl` (atalhos) | `~/.config/niri/binds.kdl` (link) |
| `home/dot_config/niri/rules.kdl` (regras de janela) | `~/.config/niri/rules.kdl` (link) |
| `home/dot_config/noctalia/config.toml` | `~/.config/noctalia/config.toml` (link) |

Os pacotes ficam nos grupos `desktop` e `keyboard`. Editar e salvar já vale, porque o niri recarrega sozinho.
O `just lint` roda o `niri validate`.

- **Monitores:** cada monitor é reconhecido pelo modelo (`niri msg outputs` mostra os nomes). Um monitor novo é só
  mais um bloco `output` no `config.kdl`. Com a tampa fechada, o niri apaga a tela do notebook sozinho.
- **Noctalia:** o que você muda pela tela de ajustes (`Alt+Shift+,`) vai para `~/.local/state/noctalia/settings.toml`,
  por cima do repo. `just noctalia-diff` mostra esses ajustes; o que quiser manter, copie para o `config.toml`.

## Atalhos

Abaixo, os principais; `Alt+Shift+/` mostra todos na tela. **Alt** cuida das janelas, como no i3. **Alt+Shift**
também abre apps e o sistema: o Corne não tem Super na camada de uso normal. Use o Alt da esquerda; o da direita
é o AltGr, dos acentos.

| Tecla | O que faz |
| --- | --- |
| `Alt+Enter` | Terminal (Ghostty) |
| `Alt+d` | Launcher |
| `Alt+Shift+q` | Fecha a janela |
| `Alt+Tab` | Troca de janela |
| `Alt+o` | Visão geral (digite para buscar um app) |
| `Alt+j/k/l/;` (ou setas) | Foco: coluna à esquerda, janela abaixo, acima, coluna à direita |
| `Alt+Shift+j/k/l/;` | Move a coluna ou a janela |
| `Alt+Ctrl+j/k/l/;` | Foco no monitor vizinho (com `Shift`, leva a coluna) |
| `Alt+1..0` / `Alt+Shift+1..0` | Vai para a área N / leva a coluna para lá |
| `` Alt+` `` | Volta para a área anterior |
| `Alt+[` / `Alt+]` | Junta a janela na coluna vizinha / separa |
| `Alt+r` | Largura da coluna: 1/3, 1/2, 2/3 |
| `Alt+-` / `Alt+=` | Largura −10% / +10% (com `Shift`, altura) |
| `Alt+f` / `Alt+Shift+f` | Tela cheia / maximiza a coluna |
| `Alt+Shift+c` | Centraliza a coluna |
| `Alt+Shift+Space` / `Alt+Space` | Janela flutuante / alterna entre flutuantes e lado a lado |
| `Alt+w` | Coluna em abas |
| `Alt+Shift+d` | Desenhar na tela (wayscriber); de novo para sair |
| `Alt+Shift+b` | Navegador (Zen) |
| `Alt+Shift+y` | Arquivos (yazi) |
| `Alt+Shift+n` | Nota do dia no Neovim (`~/notas/AAAA-MM-DD.md`) |
| `Alt+Shift+v` | Histórico de cópias |
| `Alt+Shift+s` | Central de controle |
| `Alt+Shift+,` | Ajustes do Noctalia |
| `Alt+Shift+x` | Bloquear a tela |
| `Alt+Shift+t` | Trocar o tema ([themes.md](themes.md)) |
| `Print` | Captura de uma área (ajuste e confirme com `Enter`) |
| `Ctrl+Print` / `Alt+Print` | Captura da tela / da janela |
| `Alt+Shift+Print` | Captura com anotação no satty: setas, texto, borrão. `Enter` copia; `Ctrl+S` salva |
| Teclas de mídia | Tocar/pausar, próxima e anterior, no player que está tocando (o mesmo da barra). O stop pausa: o stop de verdade fecha a sessão do YouTube e nada volta a tocar. No Corne, a tecla `Play` do Vial (`KC_MPLY`) é tocar/pausar |
| Teclas de volume e brilho | Volume, mudo e brilho da tela (pelo Noctalia) |
| `Alt+Shift+p` | Apaga os monitores |
| `Alt+Shift+Escape` | Libera os atalhos para o app em foco (ex.: uma máquina virtual) |
| `Alt+Shift+e` | Sai do niri |

As capturas vão para o clipboard e para `~/Pictures/Screenshots`.

## Teclado

- **Layout:** `us intl` (acentos por teclas mortas: `'` e depois `a` dá `á`), escrito no `config.kdl` para valer
  igual em qualquer máquina. Nos apps GTK (o Ghostty), as teclas mortas dependem do `GTK_IM_MODULE=simple` do
  `environment`: desde o GTK 4.20, sem um método de entrada (ibus, fcitx), o GTK no Wayland não compõe sozinho.
- **Corne:** o layout vive no firmware (Vial). Para mudar, abra o `Vial`, mude ao vivo e salve por cima de
  `keyboard/corne/corne.vil`; o passo a passo está no [keyboard/README.md](../keyboard/README.md). O pacote
  `vial-appimage` já traz a regra udev que deixa o Vial falar com o teclado.
- **Teclado do notebook:** sem remapeamento. O Corne já faz o Caps como Esc e Ctrl no firmware; o kanata volta se
  fizer falta.

## Por que assim

- Pacotes explícitos no grupo `desktop`, sem o meta-pacote `cachyos-niri-noctalia`: a config dele fica fora do repo e
  traz o que não usamos (alacritty, steam).
- Um arquivo só para os monitores: o niri ignora o que não está ligado, então não há arquivo por máquina.
- Alt nas janelas é o hábito do i3. Como o Alt é do niri, o tmux e o Neovim não têm atalhos com Alt.
- Notas em Markdown, e não Org mode: o Org só abre no Neovim ou no Emacs.
- O blur fica, mesmo suspeito de atrasos de até 357 ms na entrada (Intel). Se o atraso voltar, olhe o log do niri.
