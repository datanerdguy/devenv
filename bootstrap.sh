#!/usr/bin/env bash
# Prepara uma máquina nova: pacotes de sistema da distro, Nix e o home-manager.
# Uso: ./bootstrap.sh <host>     (ex.: ./bootstrap.sh fedora-laptop)
set -euo pipefail

host="${1:?informe o host, ex.: ./bootstrap.sh fedora-laptop}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Pacotes que precisam de root, pela distro.
# shellcheck disable=SC1091
. /etc/os-release
case "${ID}" in
  fedora) "${repo_dir}/system/fedora.sh" ;;
  ubuntu | debian | pop | linuxmint) "${repo_dir}/system/ubuntu.sh" ;;
  *) echo "Distro '${ID}' sem script em system/. Pulando pacotes de sistema." ;;
esac

# 2. Nix (instalador da Determinate Systems: flakes ligados, desinstalação limpa).
if ! command -v nix >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Cache binário dos agentes (llm-agents.nix): sem ele, Codex e outros compilam do zero.
# O instalador da Determinate lê ajustes locais de nix.custom.conf.
nix_conf=/etc/nix/nix.custom.conf
[ -f "${nix_conf}" ] || nix_conf=/etc/nix/nix.conf
if ! grep -qs cache.numtide.com "${nix_conf}"; then
  printf '%s\n' \
    "extra-substituters = https://cache.numtide.com" \
    "extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" |
    sudo tee -a "${nix_conf}" >/dev/null
  sudo systemctl restart nix-daemon 2>/dev/null || true
fi

# 3. Aplica a configuração do host.
nix run "${repo_dir}#home-manager" -- switch --flake "${repo_dir}#${host}" -b backup

echo "Pronto. Abra um novo terminal (Ghostty) para entrar no fish."
