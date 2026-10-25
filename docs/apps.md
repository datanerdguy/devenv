# Apps do desktop

Módulo: [`modules/apps`](../modules/apps/default.nix) (`devenv.apps.enable`). Cores: [themes.md](themes.md).

Apps gráficos não vêm do Nix: fora do NixOS eles não acham a GPU sem ajuda ([ADR 0001](adr/0001-nix-home-manager-sobre-a-distro.md)).

- **Flathub (Flatpak)**: os apps grandes. A lista fica no módulo e o [nix-flatpak](https://github.com/gmodena/nix-flatpak) instala no `just switch`, em segundo plano. Eles se atualizam uma vez por semana.
  Na primeira instalação, os downloads levam alguns minutos depois do switch. Para acompanhar:
  `journalctl --user -u flatpak-managed-install -f`.
- **Distro** (`system/<distro>.sh`): Flameshot, wayscriber, zathura, imv e mpv, junto com o próprio Flatpak.
  No Arch, o wayscriber vem do AUR (`wayscriber-bin`): o bootstrap usa o paru ou o yay, ou instala o paru se não houver nenhum.

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

Na primeira vez, abra o app e escolha *Abrir pasta como cofre* → `~/notes`. Para as cores seguirem o tema do sistema, ligue o trecho de CSS `devenv-theme` ([themes.md](themes.md#obsidian)).

## Histórico de cópias

O Noctalia guarda as últimas **30 cópias**, de texto e de imagem (captura de tela, imagem copiada do navegador).
`Super+V` abre a lista: digite para filtrar, `Enter` cola no app em foco. Dá para fixar um item para ele
não sair da lista (os fixados não contam nos 30).

- O que você copia no Neovim, no tmux e no terminal também entra (eles mandam para a área de transferência do sistema).
- Cópias de apps que já fecharam continuam disponíveis.
- A lista fica guardada criptografada em `~/.local/state/noctalia`, então sobrevive a um reinício.
  Para apagar tudo: `noctalia msg clipboard-clear`. Senhas copiadas do Bitwarden também entram; apague depois de usar.
- Para mudar o tamanho: `clipboard_history_max_entries` em [`config/noctalia/devenv.toml`](../config/noctalia/devenv.toml).

Funciona no niri e no sway (`Super+v`). No i3 (X11), onde o Noctalia não roda, quem faz o papel é o
[greenclip](https://github.com/erebe/greenclip), pelo rofi, com o mesmo `Super+v`: 30 itens, texto e imagens.
Senhas copiadas do app do Bitwarden ficam de fora. A lista fica em `~/.cache/greenclip.history`; para apagar,
`greenclip clear`.

## Captura de tela

- `Print`: Flameshot. Selecione a área e anote. `Ctrl+C` copia, `Ctrl+S` salva em `~/Pictures/Screenshots`, `Enter` copia e fecha.

Na primeira captura, o portal do desktop pede permissão. Clique em **Permitir**; se negar sem querer,
o `Print` falha com "Unable to capture screen". Para perguntar de novo:
`gdbus call --session --dest org.freedesktop.impl.portal.PermissionStore --object-path /org/freedesktop/impl/portal/PermissionStore --method org.freedesktop.impl.portal.PermissionStore.DeletePermission screenshot screenshot ''`.

A config inicial do Flameshot é criada em `~/.config/flameshot/flameshot.ini` só na primeira vez; depois, o que você muda na tela de ajustes dele fica valendo.

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

## Upload e download nos apps do Flatpak

Escolher arquivo (anexar, salvar como) passa pelo portal. No niri o seletor é o do GTK (`config/xdg-desktop-portal/niri-portals.conf`),
porque o do GNOME chama o Nautilus, que não está instalado. Se o seletor não abrir, rode `just switch` e saia e entre na sessão.
