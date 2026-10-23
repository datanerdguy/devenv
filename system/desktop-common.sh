#!/usr/bin/env bash
# Ajustes de root comuns a todas as distros para o desktop: teclados.
set -euo pipefail

# kanata (Caps Lock = Esc/Ctrl no teclado do notebook) cria um teclado virtual pelo uinput.
echo uinput | sudo tee /etc/modules-load.d/devenv-uinput.conf >/dev/null
echo 'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' |
  sudo tee /etc/udev/rules.d/60-devenv-uinput.rules >/dev/null
sudo usermod -aG input "${USER}"
sudo modprobe uinput 2>/dev/null || true

# Vial: acesso ao teclado (Corne) sem sudo.
echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"' |
  sudo tee /etc/udev/rules.d/59-devenv-vial.rules >/dev/null

# Em container não há udev rodando; as regras valem no próximo boot.
if [ -d /run/udev ]; then
  sudo udevadm control --reload-rules
  sudo udevadm trigger
fi
echo "Teclados prontos. O grupo 'input' vale a partir do próximo login."
