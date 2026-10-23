# Apps do desktop

Módulo: [`modules/apps`](../modules/apps/default.nix) (`devenv.apps.enable`).

Apps gráficos não vêm do Nix: fora do NixOS eles não acham a GPU sem ajuda ([ADR 0001](adr/0001-nix-home-manager-sobre-a-distro.md)).

- **Flathub (Flatpak)**: os apps grandes. A lista fica no módulo e o [nix-flatpak](https://github.com/gmodena/nix-flatpak) instala no `just switch`, em segundo plano. Eles se atualizam uma vez por semana.
- **Distro** (`system/<distro>.sh`): Flameshot, wayscriber, zathura, imv e mpv, junto com o próprio Flatpak.

| App | Para que | De onde | Atalho |
| --- | --- | --- | --- |
| [Zen](https://zen-browser.app) | navegador (base Firefox, abas verticais, divisão de tela) | Flathub | `Super+B` |
| Bitwarden | senhas (o `rbw` é o mesmo cofre no terminal) | Flathub | |
| [Obsidian](https://obsidian.md) | notas e zettelkasten, junto com o Neovim | Flathub | `Super+N` (no Neovim) |
| [Flameshot](https://flameshot.org) | captura com anotação (setas, texto, borrão) | distro | `Print` |
| [wayscriber](https://wayscriber.com) | desenhar por cima da tela ao explicar algo | distro | `Super+D` |
| [Rnote](https://rnote.flxzt.net) | desenho à mão e quadro branco, com mesa digitalizadora | Flathub | |
| [OBS Studio](https://obsproject.com) | gravação e transmissão com cenas | Flathub | |
| [GPU Screen Recorder](https://git.dec05eba.com/gpu-screen-recorder/about/) | gravação leve pela GPU, com replay dos últimos minutos | Flathub | |
| zathura | PDF (teclas do vim) | distro | |
| imv / mpv | imagens / vídeo e áudio | distro | |

Os apps padrão (links, PDF, imagens, vídeo) ficam em `xdg.mimeApps`, no módulo.

Para outro navegador: `devenv.apps.browser = "org.mozilla.firefox";` e ponha o id em `devenv.apps.extraFlatpaks`.
Flatpaks só deste host: `devenv.apps.extraFlatpaks = [ "com.spotify.Client" ];`.
Flatpaks instalados à mão continuam lá: o devenv só instala e atualiza os da lista.

## Notas: Obsidian + Neovim

O Obsidian e o Neovim usam o **mesmo cofre**, `~/notes` (outro lugar: `DEVENV_NOTES=/caminho`). Use cada um para o que faz melhor:

- **Neovim** ([obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim)) para escrever: `Super+N` abre a nota do dia, `<leader>zn` cria uma nota nova, `[[` liga a outra nota. Os atalhos estão em [neovim.md](neovim.md#notas-leaderz).
- **App Obsidian** para ver: o grafo das ligações, a busca, os plugins (Excalidraw, Canvas) e a sincronização.

Organização (zettelkasten):

```text
~/notes/
  zettel/     uma ideia por nota; nome = data e hora + título (202610231815-joins-no-polars.md)
  diario/     nota do dia (2026-10-23.md); o que surgir aqui vira zettel depois
  anexos/     imagens coladas
```

Os modelos (`zettel`, `conceito` com um diagrama Mermaid, `diario`) ficam no repo, em
[`config/nvim/templates/notes`](../config/nvim/templates/notes/), e o `<leader>zt` usa eles.
O cofre não vai para este repo: são dados seus. Para sincronizar, use o Obsidian Sync ou um repositório git só para o cofre.

Na primeira vez, abra o app e escolha *Abrir pasta como cofre* → `~/notes`.

## Captura de tela

- `Print`: Flameshot. Selecione a área e anote. `Ctrl+C` copia, `Ctrl+S` salva em `~/Pictures/Screenshots`, `Enter` copia e fecha.
- `Super+Print`, `Ctrl+Print`, `Alt+Print`: a captura do próprio niri (área, tela, janela), sem anotação. Ela salva e copia na hora.

O Flameshot usa o `grim` por baixo no niri (`useGrimAdapter`). A config inicial é criada em
`~/.config/flameshot/flameshot.ini` só na primeira vez; depois, o que você muda na tela de ajustes dele fica valendo.

## Desenhos e diagramas

Escolha pelo que você quer fazer:

| Para | Use |
| --- | --- |
| Explicar algo na tela, ao vivo (riscar o código, circular, seta) | **wayscriber**: `Super+D` liga e desliga, `Ctrl+W` vira quadro branco, `F9` mostra as ferramentas |
| Desenho à mão livre com a mesa, quadro infinito | **Rnote** |
| Diagrama rápido de caixas e setas no estilo esboço, junto das notas | plugin **Excalidraw** no Obsidian (*Ajustes → Plugins da comunidade → Excalidraw*) |
| Diagrama em texto, versionado (fluxo, sequência, arquitetura) | **Mermaid** num bloco ` ```mermaid ` da nota; o Obsidian desenha |

O wayscriber fica rodando em segundo plano desde o login (`spawn-at-startup` no niri), então o `Super+D` abre na hora.

A mesa digitalizadora funciona pelo libinput, com pressão no Rnote e no Excalidraw. A área dela fica no notebook;
para mudar, veja [desktop.md](desktop.md#mesa-digitalizadora).

## Gravação de tela

- **GPU Screen Recorder** para o dia a dia: grava pela GPU (NVENC na NVIDIA, VA-API na Intel/AMD), quase sem custo de CPU,
  e tem *replay*: guarda os últimos minutos e salva só quando você pede.
- **OBS Studio** para vídeos com cenas, webcam por cima, várias fontes ou transmissão ao vivo.

Os dois pedem a tela pelo portal do Wayland (uma janela para escolher o monitor ou a janela).
