# 0004. Desktop: niri + Noctalia pela distro, config ligada ao repo

Data: 2026-10-23 · Status: aceita

## Contexto

O fluxo é guiado pelo teclado, com dois monitores (ultrawide e notebook) e GPU NVIDIA. O desktop precisa abrir
rápido, ser configurado em texto versionado e funcionar no Fedora e no Ubuntu. Compositor, shell e tela de login
dependem de PAM, GPU, polkit e sessão do sistema, que o home-manager sozinho não instala bem fora do NixOS.

## Decisão

- **niri** como compositor principal e **Noctalia Shell v5** (barra, launcher, notificações, bloqueio) sobre ele.
- **Pacotes da distro** para niri, Noctalia, portais e xwayland-satellite (Fedora 44+; Ubuntu 26.04+ com PPA e o
  repositório APT do Noctalia). O Nix fica com as ferramentas do usuário.
- **Config em KDL/TOML no repo**, ligada por link fora da store: editar já vale, sem switch. Ajustes da máquina
  (monitores) em arquivos locais incluídos como opcionais.
- **Tela de login da distro** continua (LightDM no Fedora i3 Spin, GDM no Workstation e no Ubuntu); a sessão que já existia (i3 ou GNOME) fica de reserva.
- **sway** e **i3** como sessões opcionais, com atalhos básicos compartilhados (`config/wm/common.conf`).
- **kanata** no teclado do notebook (Caps = Esc/Ctrl), como serviço do usuário. O Corne fica no **Vial**,
  com o `.vil` no repo e o mapa das camadas gerado em `docs/keyboard.md`.
- **NVIDIA**: perfil do driver que limita a VRAM presa pelo compositor.
- **Validação no CI**: `niri validate`, `sway --validate` (headless), `i3 -C`, `kanata --check` como check do flake,
  e os scripts de sistema rodados em containers Fedora e Ubuntu.

## Alternativas consideradas

- **Hyprland, GNOME com extensões:** o Hyprland é mais pesado e muda a config com frequência; o GNOME não é
  orientado a teclado sem várias extensões.
- **niri e Noctalia pelo Nix:** precisa de nixGL para a GPU, a sessão não aparece na tela de login sozinha, e o nixpkgs ainda
  tem o Noctalia v4 (QML), não o v5.
- **waybar + walker + mako:** mais peças para configurar e temar; fica como plano B se o Noctalia falhar.
- **greetd/tuigreet:** mais leve, mas troca uma peça que já funciona.
- **keyd:** faz o mesmo que o kanata, mas roda como root no sistema; o kanata roda como usuário e é configurável pelo Nix.
- **QMK Configurator, ZMK Studio:** exigiriam trocar o firmware do Corne sem ganho sobre o Vial.

## Consequências

- Ubuntu 24.04 fica sem desktop (sem pacote do Noctalia); o resto do devenv funciona.
- ~~A config do Noctalia não é validada no CI (o nixpkgs só tem o v4).~~ Atualização (fase 5): o nixpkgs ganhou o
  pacote `noctalia` (v5), e o CI agora roda `noctalia config validate` com cada tema.
- Mudanças feitas pela tela de ajustes do Noctalia ficam fora do repo até serem copiadas (`just noctalia-diff`).
- O grupo `input` (kanata) só vale depois de um novo login.
