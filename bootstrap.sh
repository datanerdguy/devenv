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

# 3. Aplica a configuração do host.
nix run "${repo_dir}#home-manager" -- switch --flake "${repo_dir}#${host}" -b backup

echo "Pronto. Abra um novo terminal (Ghostty) para entrar no fish."
