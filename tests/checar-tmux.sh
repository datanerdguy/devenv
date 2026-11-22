#!/usr/bin/env bash
# Lê a config do tmux ($1) num tmux à parte (socket próprio) e falha com a mensagem de qualquer erro.
# Usado pelo just lint e pelo smoke.
set -uo pipefail

sock="devenv-check-$$"
tmux -L "${sock}" -f /dev/null new-session -d || exit 1
tmux -L "${sock}" source-file "$1"
rc=$?
tmux -L "${sock}" kill-server
exit "${rc}"
