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
  sudo mkdir -p /etc/apparmor.d
  sudo tee /etc/apparmor.d/bwrap >/dev/null <<'PROFILE'
abi <abi/4.0>,
include <tunables/global>

profile bwrap /usr/bin/bwrap flags=(unconfined) {
  userns,
  include if exists <local/bwrap>
}
PROFILE
  # Sem systemd (container), o perfil vale no próximo boot.
  if [ -d /run/systemd/system ]; then sudo systemctl reload apparmor; fi
fi

# Ghostty: pacote .deb da comunidade (https://github.com/mkasberg/ghostty-ubuntu).
if ! command -v ghostty >/dev/null; then
  # O instalador baixa o .deb na pasta atual; roda numa pasta temporária.
  (cd "$(mktemp -d)" && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)")
fi

# Desktop: niri + Noctalia v5. Precisa do Ubuntu 26.04+ (o Noctalia só tem pacote para ele).
# shellcheck disable=SC1091
. /etc/os-release
if dpkg --compare-versions "${VERSION_ID:-0}" ge 26.04 || [ "${ID}" = debian ]; then
  # niri: do repositório da distro se houver; senão, do PPA (Ubuntu 25.10+).
  if ! apt-cache show niri >/dev/null 2>&1 && [ "${ID}" = ubuntu ]; then
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:avengemedia/danklinux
  fi
  # Noctalia: repositório APT oficial do projeto.
  if [ ! -f /etc/apt/sources.list.d/noctalia.sources ]; then
    tmp="$(mktemp -d)"
    curl -fsSL -o "${tmp}/keyring.deb" https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb
    sudo dpkg -i "${tmp}/keyring.deb"
    suite=resolute
    [ "${ID}" = debian ] && suite="${VERSION_CODENAME}"
    sudo curl -fsSL -o /etc/apt/sources.list.d/noctalia.sources "https://pkg.noctalia.dev/deb/noctalia-${suite}.sources"
    rm -rf "${tmp}"
  fi
  sudo apt-get update
  sudo apt-get install -y niri noctalia xdg-desktop-portal-gnome xdg-desktop-portal-gtk
  sudo apt-get install -y xwayland-satellite || echo "xwayland-satellite indisponível: apps X11 não abrem no niri."
  if [ "${DEVENV_SWAY:-0}" = 1 ]; then sudo apt-get install -y sway; fi
  if [ "${DEVENV_I3:-0}" = 1 ]; then sudo apt-get install -y i3 xserver-xorg; fi
  "$(dirname "${BASH_SOURCE[0]}")/desktop-common.sh"
else
  echo "Ubuntu ${VERSION_ID}: sem pacotes do niri/Noctalia (precisa do 26.04). Pulando o desktop."
fi

# GPU NVIDIA: só se a placa existir.
if lspci | grep -qi 'nvidia'; then
  echo "GPU NVIDIA detectada: instalando o driver recomendado."
  sudo ubuntu-drivers install
  "$(dirname "${BASH_SOURCE[0]}")/nvidia-wayland.sh"
else
  echo "Sem GPU NVIDIA: pulando driver."
fi
