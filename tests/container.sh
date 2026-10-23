#!/usr/bin/env bash
# Instala o devenv do zero dentro de um container limpo da distro e roda os testes.
# Uso: tests/container.sh fedora:latest | ubuntu:24.04
set -euo pipefail

image="${1:?informe a imagem, ex.: tests/container.sh fedora:latest}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker run --rm -v "${repo_dir}:/src:ro" "${image}" bash -euo pipefail -c '
  if command -v dnf >/dev/null; then
    dnf install -y -q curl xz tar git sudo shadow-utils procps-ng
  else
    apt-get update -qq && apt-get install -y -qq curl xz-utils git sudo procps
  fi
  useradd -m -s /bin/bash dev
  echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev
  cp -r /src /home/dev/devenv && chown -R dev:dev /home/dev/devenv

  sudo -iu dev bash /home/dev/devenv/tests/container-user.sh
'
