# Desktop: niri + Noctalia

Sessão principal: **[niri](https://github.com/niri-wm/niri)** (janelas em colunas que rolam na horizontal) com o
**[Noctalia Shell](https://noctalia.dev)** v5 (barra, launcher, notificações, central de controle, tela de bloqueio).
**sway** e **i3** ficam como sessões opcionais, com os mesmos atalhos básicos.
Módulo: [`modules/desktop`](../modules/desktop/default.nix) (`devenv.desktop.enable`). Apps: [apps.md](apps.md). Decisão: [ADR 0004](adr/0004-desktop-niri-noctalia.md).

## Instalação

O `./bootstrap.sh <host>` instala pela distro o que precisa de root:

| Distro | O que vem |
| --- | --- |
| Fedora 44+ | `niri`, `noctalia`, `xwayland-satellite` e os portais, todos dos repositórios oficiais |
| Ubuntu 26.04+ | `niri` (do arquivo ou do PPA `avengemedia/danklinux`), `noctalia` do [repositório APT do projeto](https://docs.noctalia.dev) |
| Ubuntu 24.04 | sem desktop (não há pacote do Noctalia); o resto do devenv funciona |

Também em todas: regra udev do uinput e grupo `input` (para o kanata) e a regra udev do Vial.
Com placa NVIDIA, o perfil que reduz a VRAM presa pelo compositor ([guia do niri](https://github.com/niri-wm/niri/wiki/Nvidia)).

Para as sessões opcionais: `DEVENV_SWAY=1 DEVENV_I3=1 ./bootstrap.sh <host>` e, no host,
`devenv.desktop.sway.enable = true;` / `devenv.desktop.i3.enable = true;`.

Depois, saia da sessão e escolha **niri** na tela de login (LightDM no Fedora i3 Spin, GDM no Workstation e no
Ubuntu). A sessão que você já tinha (i3 ou GNOME) continua lá: se algo der errado, é só escolher ela na mesma tela.

No **Fedora i3 Spin** o i3 já vem configurado. O `devenv.desktop.i3.enable` troca o seu `~/.config/i3` pela config do
repo (o home-manager guarda o antigo como `config.backup`), por isso fica desligado no host até você querer.

## Como a configuração funciona

| O quê | Fonte no repo | Onde fica |
| --- | --- | --- |
| niri | `config/niri/` (`config.kdl`, `binds.kdl`, `rules.kdl`) | `~/.config/niri` (link) |
| Noctalia | `config/noctalia/*.toml` | `~/.config/noctalia` (link) |
| sway / i3 | `config/sway/`, `config/i3/`, `config/wm/common.conf` | `~/.config/sway`, `~/.config/i3`, `~/.config/devenv/wm-common.conf` |
| kanata | gerado pelo módulo | `~/.config/kanata/kanata.kbd` + serviço `kanata` do systemd do usuário |

As configs são links para o repo: editar e salvar já vale (o niri recarrega sozinho, o sway e o i3 com `Super+Shift+C`).
Para conferir antes: `just desktop-check` valida niri, sway, i3, kanata e o mapa do teclado, igual ao CI.

### Ajustes só desta máquina

- **niri**: `~/.config/devenv/niri-local.kdl` (fora do repo; o niri lê se existir). É onde ficam os monitores.
- **sway / i3**: `~/.config/devenv/sway-local.conf` e `i3-local.conf`.
- **Noctalia**: o que você muda pela tela de ajustes (`Super+,`) vai para `~/.local/state/noctalia/settings.toml`,
  por cima do repo. `just noctalia-diff` mostra esses ajustes; o que quiser manter, copie para `config/noctalia/`.

## Atalhos (niri)

`Super+Shift+/` mostra todos na tela. O padrão segue o Neovim e o tmux: `h/j/k/l` andam, `Ctrl` move, `Shift` muda de monitor.

| Tecla | O que faz |
| --- | --- |
| `Super+Enter` | terminal (Ghostty) |
| `Super+Space` | launcher do Noctalia |
| `Super+E` | arquivos (yazi) |
| `Super+S` | central de controle (Wi-Fi, som, energia) |
| `Super+,` | ajustes do Noctalia |
| `Alt+Tab` | troca de janela |
| `Super+Q` | fecha a janela |
| `Super+O` | visão geral (digite para buscar um app) |
| `Super+h/j/k/l` | foco: coluna à esquerda, janela abaixo, acima, coluna à direita |
| `Super+Ctrl+h/j/k/l` | move a coluna ou a janela |
| `Super+Shift+h/j/k/l` | foco no monitor vizinho |
| `Super+Shift+Ctrl+h/j/k/l` | leva a coluna para o monitor vizinho |
| `Super+u` / `Super+i` | área de trabalho abaixo / acima |
| `Super+Ctrl+u/i`, `Super+Ctrl+1..9` | leva a coluna para outra área |
| `Super+1..9`, `Super+Tab` | vai para a área N, volta para a anterior |
| `Super+[` / `Super+]` | junta a janela na coluna vizinha / separa |
| `Super+R` | alterna a largura da coluna (1/3, 1/2, 2/3) |
| `Super+-` / `Super+=` | largura −10 % / +10 % (com `Shift`, altura) |
| `Super+F`, `Super+Shift+F` | maximiza a coluna, tela cheia |
| `Super+C` | centraliza a coluna |
| `Super+V`, `Super+Shift+V` | janela flutuante, alterna foco entre flutuantes e lado a lado |
| `Super+W` | coluna em abas |
| `Super+B` | navegador |
| `Super+N` | nota do dia no Neovim |
| `Super+D` | desenhar na tela (wayscriber) |
| `Print` | captura com anotação (Flameshot) |
| `Super+Print`, `Ctrl+Print`, `Alt+Print` | captura nativa do niri: área, tela, janela (salva em `~/Pictures/Screenshots` e copia) |
| `Super+Alt+L` | bloqueia a tela |
| `Super+Escape` | libera os atalhos para o app em foco (VM, jogo) |
| `Super+Shift+E` | sai do niri |
| `Super+Shift+P` | desliga os monitores |

Volume, brilho e mídia funcionam pelas teclas do notebook, inclusive com a tela bloqueada.

No sway e no i3 os atalhos básicos são os mesmos (`Super+Enter`, `Super+Q`, `h/j/k/l`, `Ctrl` move, `Super+1..9`);
o resto segue o padrão deles (`Super+r` redimensiona, `Super+w` abas). A lista está em [`config/wm/common.conf`](../config/wm/common.conf).

## Monitores

Não precisa configurar nada: a cada monitor conectado o niri lê a resolução, a taxa e a escala que ele anuncia e
aplica na hora; ao desconectar, as janelas voltam para a tela que sobrou. Configure só para mudar a posição ou
forçar uma escala. A regra vale sempre que aquele monitor aparecer. Veja os nomes com `niri msg outputs`
e crie `~/.config/devenv/niri-local.kdl`:

```kdl
output "eDP-1" {
    scale 1.25
    position x=0 y=0
}
output "DP-1" {
    mode "3440x1440@100"
    position x=1536 y=0
}
```

Em vez do conector (`DP-1`), dá para usar a marca, o modelo e o número de série que o `niri msg outputs` mostra
(ex.: `output "Dell Inc. U3423WE ABC123"`): a regra segue o monitor em qualquer porta ou dock.
Sem o monitor externo, as áreas de trabalho dele passam para o notebook e voltam quando ele é ligado.

## Mesa digitalizadora

Funciona pelo libinput, sem driver extra. Por padrão a área da mesa vai para a tela do notebook
(`tablet { map-to-output "eDP-1"; }` no `config.kdl`). Para mapear para o ultrawide, repita o bloco no
`niri-local.kdl` com o nome dele.

## Teclado

### Corne (Vial)

O Corne v4.1 continua no **Vial**: muda ao vivo, sem gravar firmware, e o `.vil` vai para o repo.
Avaliamos as alternativas: o QMK Configurator e o ZMK Studio exigem trocar o firmware, e nenhum faz mais que o Vial no Corne.

- O app `Vial` (o comando tem V maiúsculo) vem do Nix; a regra udev (`system/desktop-common.sh`) deixa ele abrir o teclado sem sudo.
  No navegador, [vial.rocks](https://vial.rocks) também funciona, só em navegadores baseados no Chromium.
- O layout fica em [`keyboard/corne/corne.vil`](../keyboard/corne/corne.vil). Depois de mudar no Vial,
  salve por cima dele (*File → Save current layout*), rode `just keyboard-doc` e faça commit.
- [docs/keyboard.md](keyboard.md) mostra todas as camadas e combos, gerado a partir do `.vil`.

#### Sugestão do devenv

[`keyboard/corne/corne-devenv.vil`](../keyboard/corne/corne-devenv.vil) é uma proposta para você testar
(*File → Load saved layout*). Seu layout continua salvo no outro arquivo. As mudanças:

- **Super** no lugar do Caps Lock (canto inferior esquerdo da camada 0). O niri usa Super em tudo, e o layout atual não tem.
- **Macros** na camada 2, linha de cima à esquerda: `->`, `=>`, `:=`, `|>` (Rust, Python, Go, Elixir).
  Também `~` e `` ` `` na linha do meio.
- **Camada 3 de funções e navegação**: F1–F12 nas duas linhas de cima à esquerda, mídia e brilho na de baixo,
  PgUp/PgDn/Home/End/Del/Print à direita, ao lado das setas que já existiam.
- **Combos**: `J+K` = Esc e `D+F` = Tab. O `Alt+1` = F1 que você tinha continua.

As posições seguem a matriz do arquivo, que não é a ordem física das teclas; confira no Vial antes de gravar.

### Teclado do notebook (kanata)

O [kanata](https://github.com/jtroo/kanata) roda como serviço do usuário e muda só o teclado interno:
Caps Lock vira Esc no toque e Ctrl segurando. O Corne não é afetado (ele já faz isso no firmware).

- Outro teclado: `kanata --list` mostra os nomes; ponha em `devenv.desktop.kanata.devices`.
- Tempo de toque: `devenv.desktop.kanata.tapMs` (padrão 200 ms).
- Desligar: `devenv.desktop.kanata.enable = false;`.
- Se não funcionar: `systemctl --user status kanata`. Precisa do grupo `input` (vale depois de sair e entrar de novo).

O layout do sistema é `us` com a variante `altgr-intl` (acentos com AltGr, sem teclas mortas atrapalhando o código).
Para mudar, edite `xkb` no `config.kdl`.

## GPU (NVIDIA, híbrida ou integrada)

Nada a configurar no caso comum. O bootstrap só instala o driver da NVIDIA se achar a placa, junto com o perfil de VRAM.
O niri escolhe sozinho a placa que desenha a tela: com GPU híbrida, usa a integrada e a NVIDIA fica livre para
CUDA e jogos (`__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <app>` manda um app para ela).

Se o niri abrir com tela preta, o modeset do kernel está desligado:

```bash
sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'   # Fedora
```

Para forçar uma placa (ex.: o monitor externo ligado direto na NVIDIA ficar lento), veja as placas com
`ls -l /dev/dri/by-path/` e ponha no `niri-local.kdl`:

```kdl
debug {
    render-drm-device "/dev/dri/renderD129"
}
```

## Voltar atrás

- Para não usar o niri: escolha a sessão antiga (i3 ou GNOME) na tela de login. Nada dela é removido.
- Para tirar a config: `devenv.desktop.enable = false;` e `just switch`.
- Para voltar a uma versão anterior da config: `just generations` e ative a geração desejada.
