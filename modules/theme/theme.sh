# shellcheck shell=bash disable=SC2154 # THEMES, STATE e DEFAULT_* vêm do módulo (default.nix)
# theme: troca o tema de todos os apps de uma vez (docs/themes.md).
# Variáveis vindas do módulo: THEMES (pasta com os temas), STATE, DEFAULT_THEME, DEFAULT_OPACITY.

usage() {
  cat <<'EOF'
uso: theme [nome]            troca o tema (sem nome: escolhe numa lista)
     theme list              lista os temas
     theme current           mostra o tema atual
     theme opacity [0.0-1.0] mostra ou muda a opacidade do fundo (1 = sólido)
     theme opacity reset     volta à opacidade do host
     theme apply             reaplica o tema salvo (o login e o `just switch` usam)
EOF
}

die() {
  echo "theme: $*" >&2
  exit 1
}

ids() { find "${THEMES}/" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort; }

current_id() {
  if [ -r "${STATE}/current/id" ]; then
    cat "${STATE}/current/id"
  else
    echo "${DEFAULT_THEME}"
  fi
}

current_opacity() {
  if [ -r "${STATE}/opacity" ]; then
    cat "${STATE}/opacity"
  else
    awk -v o="${DEFAULT_OPACITY}" 'BEGIN { print o + 0 }' # 0.950000 -> 0.95
  fi
}

# Pasta de papéis de parede: a sua (~/Pictures/Wallpapers/<tema>) se tiver imagens, senão a do tema.
wallpaper_dir() {
  local mine="${HOME}/Pictures/Wallpapers/$1"
  if [ -n "$(find "${mine}" -maxdepth 1 -type f 2>/dev/null | head -n 1)" ]; then
    echo "${mine}"
  else
    echo "${THEMES}/$1/wallpapers"
  fi
}

# Mostra as 16 cores do tema (pré-visualização da lista).
preview() {
  local dir="${THEMES}/$1" line hex n=0
  cat "${dir}/name"
  echo
  while read -r line; do
    case "${line}" in
      palette\ =*)
        hex="${line##*#}"
        printf '\033[48;2;%d;%d;%dm    \033[0m' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
        n=$((n + 1))
        [ $((n % 8)) -eq 0 ] && echo
        ;;
    esac
  done <"${dir}/ghostty"
}

pick() {
  ids | fzf --prompt "tema> " --reverse --no-multi \
    --header "atual: $(current_id)" \
    --preview "theme __preview {}" --preview-window right,60%
}

write_atomic() {
  local dest="$1"
  cat >"${dest}.tmp"
  mv -f "${dest}.tmp" "${dest}"
}

# Painel do Noctalia: sólido, suave ou vidro, conforme a opacidade.
panel_mode() {
  awk -v o="$1" 'BEGIN { if (o >= 0.99) print "solid"; else if (o >= 0.9) print "soft"; else print "glass" }'
}

noctalia_running() { command -v noctalia >/dev/null 2>&1 && noctalia msg status >/dev/null 2>&1; }

# Manda o Noctalia usar a paleta do tema atual e um papel de parede dele
# (se o papel de parede atual já é do tema, fica o que você escolheu).
sync_noctalia() {
  noctalia_running || return 0
  local id name walls first
  id="$(current_id)"
  name="$(cat "${THEMES}/${id}/name")"
  walls="$(wallpaper_dir "${id}")"
  noctalia msg config-reload >/dev/null 2>&1 || true
  noctalia msg color-scheme-set custom "${name}" >/dev/null 2>&1 || true
  if ! noctalia msg wallpaper-get 2>/dev/null | grep -qF "${walls}"; then
    first="$(find -L "${walls}" -maxdepth 1 -type f | sort | head -n 1)"
    [ -n "${first}" ] && noctalia msg wallpaper-set "${first}" >/dev/null 2>&1
  fi
  return 0
}

# Chamado pelo Noctalia ao abrir (hook `started`): espera o IPC dele e sincroniza.
# Cobre o tema trocado com o Noctalia fechado (ex.: na sessão i3).
sync_noctalia_on_start() {
  local i
  command -v noctalia >/dev/null 2>&1 || return 0
  for i in 1 2 3 4 5 6 7 8 9 10; do
    noctalia_running && break
    [ "${i}" -lt 10 ] && sleep 0.5
  done
  sync_noctalia
}

apply() {
  local id="$1" dir opacity name
  dir="${THEMES}/${id}"
  [ -d "${dir}" ] || die "tema desconhecido: ${id} (veja: theme list)"
  opacity="$(current_opacity)"
  name="$(cat "${dir}/name")"
  mkdir -p "${STATE}"

  ln -sfn "${dir}" "${STATE}/current"
  echo "${opacity}" | write_atomic "${STATE}/active-opacity" # o Neovim lê daqui

  # Ghostty: cores do tema + opacidade (a config do Ghostty inclui este arquivo).
  { cat "${dir}/ghostty"; echo "background-opacity = ${opacity}"; } | write_atomic "${STATE}/ghostty"
  # niri: cores das bordas (o config.kdl inclui este arquivo e recarrega sozinho).
  write_atomic "${STATE}/niri.kdl" <"${dir}/niri.kdl"
  # Noctalia: paleta, pasta de papéis de parede e transparência dos painéis.
  write_atomic "${STATE}/noctalia.toml" <<EOF
# Gerado pelo comando theme. Não edite: rode \`theme <nome>\` ou \`theme opacity <n>\`.
[theme]
source = "custom"
custom_palette = "${name}"
mode = "dark"

[wallpaper]
directory = "$(wallpaper_dir "${id}")"

[shell.panel]
transparency_mode = "$(panel_mode "${opacity}")"
EOF

  # Avisa os apps abertos. Nenhum desses passos falha o comando.
  pkill -USR2 -x ghostty 2>/dev/null || true # Ghostty recarrega a config
  pkill -USR1 -x nvim 2>/dev/null || true    # Neovim troca o colorscheme (lua/devenv/theme.lua)
  if command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; then
    tmux source-file "${dir}/tmux.conf" 2>/dev/null || true
  fi
  sync_noctalia
}

cmd="${1:-}"
case "${cmd}" in
  -h | --help | help) usage ;;
  list) ids ;;
  current) current_id ;;
  apply) apply "$(current_id)" ;;
  __preview) preview "$2" ;;
  __sync-noctalia) sync_noctalia_on_start ;;
  opacity)
    case "${2:-}" in
      "") current_opacity ;;
      reset) rm -f "${STATE}/opacity" && apply "$(current_id)" ;;
      *)
        awk -v o="$2" 'BEGIN { exit !(o ~ /^[0-9.]+$/ && o >= 0 && o <= 1) }' \
          || die "opacidade entre 0 e 1 (ex.: 0.9)"
        mkdir -p "${STATE}"
        echo "$2" >"${STATE}/opacity"
        apply "$(current_id)"
        ;;
    esac
    ;;
  "")
    choice="$(pick)" || exit 0
    apply "${choice}"
    echo "tema: $(cat "${THEMES}/${choice}/name")"
    ;;
  *)
    apply "${cmd}"
    echo "tema: $(cat "${THEMES}/${cmd}/name")"
    ;;
esac
