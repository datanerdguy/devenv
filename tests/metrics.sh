#!/usr/bin/env bash
# Tamanho do repo por área, em TSV, para comparar o antes e o depois da refatoração (ADR 0009).
#   tests/metrics.sh > antes.tsv; ...; tests/metrics.sh > depois.tsv; diff antes.tsv depois.tsv
# Conta só arquivos versionados de texto: imagens, JSON, o .vil e as licenças dos modelos ficam de fora.
set -euo pipefail
cd "$(dirname "$0")/.."

areas=(
  agents modules hosts system tests .github docs
  config/nvim config/niri config/noctalia config/sway config/i3 config/wm
  themes templates keyboard
)

printf 'metrica\tarquivos\tlinhas\n'
for area in "${areas[@]}"; do
  mapfile -t files < <(git ls-files "$area" | grep -vE '\.(svg|png|jpg|json|vil)$|\.min\.js$|/licenses/')
  lines=0
  if ((${#files[@]})); then lines="$(cat "${files[@]}" | wc -l)"; fi
  printf '%s\t%s\t%s\n' "$area" "${#files[@]}" "$lines"
done
root=(AGENTS.md README.md bootstrap.sh flake.nix justfile)
printf 'raiz\t%s\t%s\n' "${#root[@]}" "$(cat "${root[@]}" | wc -l)"

printf 'nvim_plugins\t%s\t-\n' "$(jq '.plugins | length' config/nvim/nvim-pack-lock.json)"
