#!/usr/bin/env bash
# Pacotes de sistema no Ubuntu/Debian. Tudo o mais vem do Nix (home-manager).
set -euo pipefail

sudo apt-get update
sudo apt-get install -y git curl fish pciutils build-essential

# Ghostty: pacote .deb da comunidade (https://github.com/mkasberg/ghostty-ubuntu).
if ! command -v ghostty >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
fi

# GPU NVIDIA: só se a placa existir.
if lspci | grep -qi 'nvidia'; then
  echo "GPU NVIDIA detectada: instalando o driver recomendado."
  sudo ubuntu-drivers install
else
  echo "Sem GPU NVIDIA: pulando driver."
fi
