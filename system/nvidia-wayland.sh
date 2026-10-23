#!/usr/bin/env bash
# NVIDIA + Wayland: ajustes do guia do niri (https://github.com/niri-wm/niri/wiki/Nvidia).
set -euo pipefail

# O driver segura ~1 GiB de VRAM no compositor em vez de ~100 MiB; este perfil corrige.
dir=/etc/nvidia/nvidia-application-profiles-rc.d
sudo mkdir -p "${dir}"
sudo tee "${dir}/50-limit-free-buffer-pool-in-wayland-compositors.json" >/dev/null <<'JSON'
{
  "rules": [
    { "pattern": { "feature": "procname", "matches": "niri" }, "profile": "Limit Free Buffer Pool On Wayland Compositors" },
    { "pattern": { "feature": "procname", "matches": "sway" }, "profile": "Limit Free Buffer Pool On Wayland Compositors" }
  ],
  "profiles": [
    { "name": "Limit Free Buffer Pool On Wayland Compositors", "settings": [ { "key": "GLVidHeapReuseRatio", "value": 0 } ] }
  ]
}
JSON

# Tela preta ao iniciar o niri: precisa do modeset do kernel.
modeset=/sys/module/nvidia_drm/parameters/modeset
if [ -r "${modeset}" ] && [ "$(cat "${modeset}")" != Y ]; then
  echo "Aviso: nvidia-drm.modeset está desligado. Ligue com:"
  echo "  sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'   (Fedora)"
  echo "  e adicione nvidia-drm.modeset=1 ao GRUB_CMDLINE_LINUX em /etc/default/grub (Ubuntu)"
  echo "  No Arch o nvidia-utils já liga por padrão; confira /etc/modprobe.d e reinicie."
fi
