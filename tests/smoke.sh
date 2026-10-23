#!/usr/bin/env bash
# Testes de fumaça: rodam depois do `home-manager switch` e conferem que o ambiente funciona.
set -euo pipefail

fail=0
check() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "ok    ${name}"
  else
    echo "FALHA ${name}"
    fail=1
  fi
}

export PATH="${HOME}/.nix-profile/bin:${HOME}/.local/state/nix/profile/bin:${PATH}"

for bin in fish starship git delta lazygit gh rg fd fzf bat eza zoxide atuin direnv yazi jq duckdb just; do
  check "binário ${bin}" command -v "${bin}"
done

check "fish inicia sem erro" fish -c 'exit 0'
check "abreviação ll no fish" fish -i -c 'abbr --query ll'
check "starship gera prompt" starship prompt
check "git com branch padrão main" test "$(git config --global init.defaultBranch)" = main
check "git usa delta nos diffs" sh -c 'git config --global pager.diff | grep -q delta'
check "config do ghostty" test -f "${HOME}/.config/ghostty/config"
check "config do starship" test -f "${HOME}/.config/starship.toml"
check "direnv com nix-direnv" test -f "${HOME}/.config/direnv/lib/hm-nix-direnv.sh"

exit "${fail}"
