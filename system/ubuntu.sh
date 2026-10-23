#!/usr/bin/env bash
# Pacotes de sistema no Ubuntu/Debian. Tudo o mais vem do Nix (home-manager).
set -euo pipefail

sudo apt-get update
sudo apt-get install -y git curl fish pciutils build-essential

# Sandbox nativo do Claude Code (bubblewrap isola o disco, socat leva a rede ao proxy).
sudo apt-get install -y bubblewrap socat
# Ubuntu 24.04+: o AppArmor bloqueia os namespaces que o bubblewrap usa; libera só para o bwrap.
if [ "$(sysctl -n kernel.apparmor_restrict_unprivileged_userns 2>/dev/null || echo 0)" = 1 ] \
  && [ ! -f /etc/apparmor.d/bwrap ]; then
  sudo tee /etc/apparmor.d/bwrap >/dev/null <<'PROFILE'
abi <abi/4.0>,
include <tunables/global>

profile bwrap /usr/bin/bwrap flags=(unconfined) {
  userns,
  include if exists <local/bwrap>
}
PROFILE
  sudo systemctl reload apparmor
fi

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
