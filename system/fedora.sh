#!/usr/bin/env bash
# Pacotes de sistema no Fedora: o que precisa de root ou de integração com a GPU.
# Tudo o mais vem do Nix (home-manager).
set -euo pipefail

sudo dnf install -y dnf-plugins-core git curl gcc make

# Ghostty (COPR mantido pela comunidade).
sudo dnf copr enable -y scottames/ghostty
sudo dnf install -y ghostty

# fish precisa estar no sistema para poder virar shell de login, se você quiser.
sudo dnf install -y fish

# Sandbox nativo do Claude Code (bubblewrap isola o disco, socat leva a rede ao proxy).
sudo dnf install -y bubblewrap socat

# Desktop: niri + Noctalia v5 (repositórios oficiais; o noctalia existe a partir do Fedora 44),
# portais (compartilhar tela, escolher arquivos) e xwayland-satellite (apps X11 no niri).
desktop=(niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk)
if [ "$(rpm -E %fedora)" -ge 44 ]; then
  desktop+=(noctalia)
else
  echo "Fedora $(rpm -E %fedora): sem pacote do Noctalia (precisa do 44+). O niri sobe sem barra."
fi
sudo dnf install -y "${desktop[@]}"
# Sessões alternativas, se pedidas: DEVENV_SWAY=1 / DEVENV_I3=1 ./bootstrap.sh <host>
if [ "${DEVENV_SWAY:-0}" = 1 ]; then sudo dnf install -y sway; fi
if [ "${DEVENV_I3:-0}" = 1 ]; then sudo dnf install -y i3 xorg-x11-server-Xorg; fi

"$(dirname "${BASH_SOURCE[0]}")/desktop-common.sh"

# GPU NVIDIA: só se a placa existir.
if lspci | grep -qi 'nvidia'; then
  echo "GPU NVIDIA detectada: instalando driver via RPM Fusion."
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
  "$(dirname "${BASH_SOURCE[0]}")/nvidia-wayland.sh"
else
  echo "Sem GPU NVIDIA: pulando driver."
fi
