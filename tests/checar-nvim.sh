#!/usr/bin/env bash
# Abre o Neovim sem interface com a config da pasta $1 e falha se houver erro ou aviso ao abrir, se o tema não
# carregar, se um servidor LSP ligado não tiver o comando instalado, se faltar um parser do treesitter ou se
# o lua_ls achar um uso errado da API do Neovim ou de um plugin. Usado pelo just lint (a config do repo) e pelo
# smoke (a instalada). O nvim vem de $NVIM, ou do PATH.
#
# O XDG_CONFIG_HOME é uma pasta temporária com um link para a config: o nvim do bob cria um config.toml no
# XDG_CONFIG_HOME quando não acha um, e apontar direto para o repo deixava o arquivo lá.
set -uo pipefail

nvim="${NVIM:-nvim}"
# Um erro dentro de um -c deixa o Neovim sem interface esperando; o timeout garante que a checagem termina.
run() { timeout 120 "${nvim}" --headless "$@"; }
tests="$(cd "$(dirname "$0")" && pwd)"
config="$(cd "$1" && pwd)" || exit 1
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
ln -s "${config}" "${tmp}/nvim"
export XDG_CONFIG_HOME="${tmp}"

# Na primeira vez, o vim.pack baixa os plugins e o nvim-treesitter compila os parsers; as mensagens deles não contam
# como aviso. Compilar todos leva alguns minutos, por isso o timeout maior.
timeout 900 "${nvim}" --headless \
  -c 'lua require("nvim-treesitter").install(require("plugins.treesitter").languages):wait(900000)' -c qa || exit 1
run -c 'lua
  local messages = vim.fn.execute("messages")
  if vim.v.errmsg ~= "" or messages ~= "" or not vim.g.colors_name then
    io.stderr:write(messages, "\n", vim.v.errmsg, "\n")
    vim.cmd.cquit(1)
  end' -c qa || exit 1
run -c "luafile ${tests}/checar-lsp.lua" || exit 1
run -c "luafile ${tests}/checar-treesitter.lua" || exit 1
run -c "luafile ${tests}/checar-lua.lua"
