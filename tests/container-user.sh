#!/usr/bin/env bash
# Parte de tests/container.sh que roda como o usuário de teste, dentro do container.
# Fica num arquivo próprio: passar um script de várias linhas por `sudo -i ... -c`
# perde as quebras de linha e o teste terminava cedo sem falhar.
set -euo pipefail

# Rodando via `sudo -iu`: sem isso o bob procura as pastas do root (SUDO_USER).
unset SUDO_USER SUDO_UID SUDO_GID SUDO_COMMAND
# Token vazio faria o bob mandar um cabeçalho de autenticação inválido.
[ -n "${GITHUB_TOKEN:-}" ] || unset GITHUB_TOKEN

curl -fsSL https://nixos.org/nix/install -o /tmp/nix-install
sh /tmp/nix-install --no-daemon
# shellcheck disable=SC1091
. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
export NIX_CONFIG="experimental-features = nix-command flakes
extra-substituters = https://cache.numtide.com
extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="

cd "${HOME}/devenv"
# Chave só de teste para o host ci abrir tests/secrets/ci.yaml (o smoke.sh confere).
install -D -m 600 tests/secrets/ci-age-key.txt "${HOME}/.config/sops/age/keys.txt"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
install -d -m 700 "${XDG_RUNTIME_DIR}"
nix run .#home-manager -- switch --flake .#ci -b backup
./tests/smoke.sh
