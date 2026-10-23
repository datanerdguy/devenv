#!/usr/bin/env bash
# Pacotes de sistema no Arch e derivadas (EndeavourOS, CachyOS, Manjaro). Tudo o mais vem do Nix (home-manager).
# Quase tudo vem dos repositórios oficiais; só o wayscriber vem do AUR.
set -euo pipefail

here="$(dirname "${BASH_SOURCE[0]}")"
pac() { sudo pacman -S --needed --noconfirm "$@"; }

sudo pacman -Syu --noconfirm
# base-devel e git: para compilar os pacotes do AUR.
pac base-devel git curl pciutils fish ghostty

# Sandbox nativo do Claude Code (bubblewrap isola o disco, socat leva a rede ao proxy).
pac bubblewrap socat

# Desktop: niri + Noctalia v5, portais (compartilhar tela, escolher arquivos) e xwayland-satellite (apps X11 no niri).
# adw-gtk-theme e qt6ct: apps GTK3 e Qt com as cores do tema (docs/themes.md).
pac niri noctalia xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk adw-gtk-theme qt6ct
# Sessões alternativas, se pedidas: DEVENV_SWAY=1 / DEVENV_I3=1 ./bootstrap.sh <host>
if [ "${DEVENV_SWAY:-0}" = 1 ]; then pac sway; fi
if [ "${DEVENV_I3:-0}" = 1 ]; then pac i3-wm xorg-server picom network-manager-applet feh; fi

"${here}/desktop-common.sh"

# Apps gráficos pela distro (acham a GPU sem ajuda): captura, PDF, imagem, vídeo e o Flatpak
# (os apps grandes vêm do Flathub, pelo home-manager).
pac flatpak flameshot zathura zathura-pdf-mupdf imv mpv

# AUR: usa o paru ou o yay se já houver um; senão instala o paru-bin. O makepkg não roda como root.
aur_build() {
  local dir
  dir="$(mktemp -d)"
  git clone --depth 1 "https://aur.archlinux.org/$1.git" "${dir}/$1"
  (cd "${dir}/$1" && makepkg -si --noconfirm --needed)
  rm -rf "${dir}"
}
aur() {
  if [ "${EUID}" -eq 0 ]; then
    echo "Rodando como root: pulando os pacotes do AUR ($*). Rode como seu usuário para instalá-los."
    return 0
  fi
  local helper=""
  for h in paru yay; do command -v "${h}" >/dev/null && helper="${h}" && break; done
  if [ -z "${helper}" ]; then
    aur_build paru-bin
    helper=paru
  fi
  # O paru-bin às vezes fica atrás de uma versão nova do pacman; aí compila direto.
  "${helper}" -S --needed --noconfirm "$@" || for p in "$@"; do aur_build "${p}"; done
}
# wayscriber: desenhar por cima da tela (Super+D).
aur wayscriber-bin

# GPU NVIDIA: só se a placa existir. O driver aberto serve da série GTX 16xx / RTX 20xx (Turing) em diante.
if lspci | grep -qi 'nvidia'; then
  if lspci | grep -i 'nvidia' | grep -Eqi 'GTX (6|7|9|10)[0-9]{2}|GT [67][0-9]{2}|Quadro [KMP][0-9]'; then
    echo "GPU NVIDIA anterior à Turing: o driver aberto não serve. Instale o legado do AUR (ex.: nvidia-580xx-dkms)."
  else
    echo "GPU NVIDIA detectada: instalando o driver aberto (nvidia-open-dkms)."
    headers=()
    for k in linux linux-lts linux-zen linux-hardened; do
      if pacman -Q "${k}" >/dev/null 2>&1; then headers+=("${k}-headers"); fi
    done
    pac nvidia-open-dkms nvidia-utils "${headers[@]}"
    "${here}/nvidia-wayland.sh"
  fi
else
  echo "Sem GPU NVIDIA: pulando driver."
fi
