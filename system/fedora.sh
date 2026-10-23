#!/usr/bin/env bash
# Pacotes de sistema no Fedora: o que precisa de root ou de integração com a GPU.
# Tudo o mais vem do Nix (home-manager).
set -euo pipefail

sudo dnf install -y dnf-plugins-core git curl

# Ghostty (COPR mantido pela comunidade).
sudo dnf copr enable -y scottames/ghostty
sudo dnf install -y ghostty

# fish precisa estar no sistema para poder virar shell de login, se você quiser.
sudo dnf install -y fish

# GPU NVIDIA: só se a placa existir.
if lspci | grep -qi 'nvidia'; then
  echo "GPU NVIDIA detectada: instalando driver via RPM Fusion."
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
else
  echo "Sem GPU NVIDIA: pulando driver."
fi
