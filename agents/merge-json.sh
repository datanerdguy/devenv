#!/usr/bin/env bash
# Usado pelos modify_ do chezmoi nos arquivos que o próprio Claude também edita.
# Lê o JSON atual no stdin e devolve com as chaves do fragmento ($1) por cima. Objetos se mesclam;
# listas e valores do fragmento substituem os do arquivo. O que o fragmento não cita fica como está.
set -euo pipefail

current="$(cat)"
[ -n "${current}" ] || current='{}'
jq --slurpfile extra "$1" '. * $extra[0]' <<<"${current}"
