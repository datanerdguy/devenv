#!/usr/bin/env bash
# Roda o script de sistema da distro (system/<distro>.sh) num container limpo e confere os pacotes.
# Pega nome de pacote errado, repositório fora do ar e mudança de versão da distro.
# Uso: tests/system.sh fedora:latest | ubuntu:24.04 | ubuntu:26.04
set -euo pipefail

image="${1:?informe a imagem, ex.: tests/system.sh fedora:latest}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker run --rm -e DEVENV_SWAY=1 -e DEVENV_I3=1 -v "${repo_dir}:/src:ro" "${image}" bash -euo pipefail -c '
  if command -v dnf >/dev/null; then
    # A imagem traz o systemd-standalone-tmpfiles no lugar do systemd, que conflita com o pipewire
    # (dependência do noctalia). Numa instalação real o systemd já está lá.
    dnf install -y -q --allowerasing sudo shadow-utils pciutils systemd
    script=fedora.sh
  else
    apt-get update -qq && apt-get install -y -qq sudo curl ca-certificates
    script=ubuntu.sh
  fi
  useradd -m dev
  echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev
  sudo -u dev env USER=dev DEVENV_SWAY=1 DEVENV_I3=1 bash "/src/system/${script}"

  . /etc/os-release
  bins="ghostty fish bwrap"
  # O desktop só existe no Fedora 44+ e no Ubuntu 26.04+.
  if { [ "${ID}" = fedora ] && [ "${VERSION_ID}" -ge 44 ]; } || { [ "${ID}" = ubuntu ] && dpkg --compare-versions "${VERSION_ID}" ge 26.04; }; then
    bins="${bins} niri noctalia sway i3"
  fi
  for b in ${bins}; do
    command -v "${b}" >/dev/null && echo "ok    ${b}" || { echo "FALHA ${b}"; exit 1; }
  done
  test -f /etc/udev/rules.d/60-devenv-uinput.rules && echo "ok    regra udev do uinput"
'
