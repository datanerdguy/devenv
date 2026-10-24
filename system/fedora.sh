#!/usr/bin/env bash
# Pacotes de sistema no Fedora: o que precisa de root ou de integração com a GPU.
# Tudo o mais vem do Nix (home-manager).
set -euo pipefail

# RHEL, CentOS e Alma também se dizem "fedora" no ID_LIKE, mas não têm os mesmos repositórios.
if ! [[ "$(rpm -E %fedora)" =~ ^[0-9]+$ ]]; then
  echo "Esta distro não é um Fedora (nem derivada direta): pulando pacotes de sistema."
  exit 0
fi

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
# adw-gtk3 e qt6ct: apps GTK3 e Qt com as cores do tema (docs/themes.md).
desktop=(niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk adw-gtk3-theme qt6ct)
if [ "$(rpm -E %fedora)" -ge 44 ]; then
  desktop+=(noctalia)
else
  echo "Fedora $(rpm -E %fedora): sem pacote do Noctalia (precisa do 44+). O niri sobe sem barra."
fi
sudo dnf install -y "${desktop[@]}"
# Sessões alternativas, se pedidas: DEVENV_SWAY=1 / DEVENV_I3=1 ./bootstrap.sh <host>
if [ "${DEVENV_SWAY:-0}" = 1 ]; then sudo dnf install -y sway; fi
# i3: compositor (picom), Wi-Fi na bandeja (nm-applet) e papel de parede (feh), que precisam da GPU ou do GTK da distro.
if [ "${DEVENV_I3:-0}" = 1 ]; then sudo dnf install -y i3 xorg-x11-server-Xorg picom network-manager-applet feh; fi

"$(dirname "${BASH_SOURCE[0]}")/desktop-common.sh"

# Apps gráficos pela distro (acham a GPU sem ajuda): captura, PDF, imagem, vídeo e o Flatpak
# (os apps grandes vêm do Flathub, pelo home-manager). wayscriber: repositório oficial do projeto.
if [ ! -f /etc/yum.repos.d/wayscriber.repo ]; then
  sudo tee /etc/yum.repos.d/wayscriber.repo >/dev/null <<'REPO'
[wayscriber]
name=Wayscriber Repo
baseurl=https://wayscriber.com/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://wayscriber.com/rpm/RPM-GPG-KEY-wayscriber.asc
REPO
fi
sudo dnf install -y flatpak flameshot wayscriber zathura zathura-pdf-mupdf imv mpv

# GPU NVIDIA: só se a placa existir. O driver depende da geração do chip (nome de código no lspci, ex.: GM108M):
# - Turing (TU) em diante: akmod-nvidia, o driver atual.
# - Maxwell (GM), Pascal (GP) e Volta (GV): param na série 580. No Fedora 44+ ela tem pacote próprio
#   (akmod-nvidia-580xx), porque o akmod-nvidia já é uma série que não aceita essas placas.
# - Kepler (GK) e Fermi (GF): os drivers antigos não acompanham o kernel atual. Fica o nouveau.
nvidia="$(lspci | grep -i 'nvidia' || true)"
if [ -z "${nvidia}" ]; then
  echo "Sem GPU NVIDIA: pulando driver."
elif grep -Eq '\bG[FK][0-9]{3}' <<<"${nvidia}"; then
  echo "GPU NVIDIA Kepler ou Fermi: sem driver suportado no Fedora atual. Pulando (fica o nouveau)."
else
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
  driver=(akmod-nvidia xorg-x11-drv-nvidia-cuda)
  if grep -Eq '\bG[MPV][0-9]{3}' <<<"${nvidia}" && [ -n "$(dnf -q repoquery akmod-nvidia-580xx 2>/dev/null)" ]; then
    driver=(akmod-nvidia-580xx xorg-x11-drv-nvidia-580xx-cuda)
  fi
  # Se o akmod-nvidia errado já estiver instalado (ex.: depois do upgrade do Fedora), remova antes.
  # O --allowerasing não basta: as libs da série nova ficam e têm os mesmos arquivos do 580xx.
  # O --noautoremove guarda o akmods, o kernel-devel e o envycontrol.
  if [ "${driver[0]}" = akmod-nvidia-580xx ] && rpm -q akmod-nvidia >/dev/null 2>&1; then
    mapfile -t antigos < <(rpm -qa --qf '%{NAME}\n' akmod-nvidia 'kmod-nvidia*' 'xorg-x11-drv-nvidia*' nvidia-settings |
      grep -v 580xx)
    echo "Removendo o driver que não aceita esta placa: ${antigos[*]}"
    sudo dnf remove -y --noautoremove "${antigos[@]}"
  fi
  # O 580xx escolhe entre o módulo open e o fechado procurando a placa no lspci na hora de compilar.
  # Com a GPU escondida (envycontrol no modo integrated), ele compila o open, que não aceita essas placas.
  # Este macro desliga a detecção e fixa o módulo fechado.
  if [ "${driver[0]}" = akmod-nvidia-580xx ]; then
    echo '%_without_kmod_nvidia_detect 1' | sudo tee /etc/rpm/macros.nvidia-kmod-fechado >/dev/null
  fi
  echo "GPU NVIDIA detectada: instalando ${driver[0]} via RPM Fusion."
  sudo dnf install -y "${driver[@]}"
  "$(dirname "${BASH_SOURCE[0]}")/nvidia-wayland.sh"
fi
