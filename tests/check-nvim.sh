#!/usr/bin/env bash
# Abre o Neovim sem interface com a config da pasta $1 e roda o check-nvim.lua. O nvim vem de $NVIM ou do PATH.
# Usado pelo just lint (a config do repo) e pelo smoke (a instalada).
# O XDG_CONFIG_HOME é temporário, com um link para a config: o nvim do bob cria um config.toml nele se não achar.
set -uo pipefail

nvim="${NVIM:-nvim}"
# Um erro dentro de um -c deixa o Neovim esperando; o timeout garante que a checagem termina.
run() { timeout 300 "${nvim}" --headless "$@"; }
tests="$(cd "$(dirname "$0")" && pwd)"
config="$(cd "$1" && pwd)" || exit 1
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
ln -s "${config}" "${tmp}/nvim"
export XDG_CONFIG_HOME="${tmp}"

# Na primeira vez, o vim.pack baixa os plugins e o treesitter compila os parsers (minutos, daí o timeout maior).
timeout 900 "${nvim}" --headless \
  -c 'lua require("nvim-treesitter").install(require("plugins.treesitter").languages):wait(900000)' -c qa || exit 1
run -c "luafile ${tests}/check-nvim.lua"
