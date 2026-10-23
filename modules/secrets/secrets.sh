# shellcheck shell=bash
# O comando `secrets` (docs/secrets.md). DEFAULT_REPO e DEFAULT_HOST vêm do módulo (secrets.nix).
#   secrets init [host]     cria a chave age (se faltar), o .sops.yaml e secrets/<host>.yaml
#   secrets edit [host]     abre secrets/<host>.yaml decifrado no $EDITOR (o sops cifra ao salvar)
#   secrets restore         traz a chave do Bitwarden (nota devenv-age-key) numa máquina nova
#   secrets status          mostra a chave e os segredos abertos nesta sessão

repo="${DEVENV_REPO:-${DEFAULT_REPO}}"
key_file="${SOPS_AGE_KEY_FILE:-${XDG_CONFIG_HOME:-${HOME}/.config}/sops/age/keys.txt}"
bw_item=devenv-age-key

usage() {
  cat <<'USAGE'
Uso:
  secrets init [host]     cria a chave age (se faltar), o .sops.yaml e secrets/<host>.yaml
  secrets edit [host]     abre secrets/<host>.yaml decifrado no $EDITOR (o sops cifra ao salvar)
  secrets restore         traz a chave do Bitwarden (item devenv-age-key) numa máquina nova
  secrets status          mostra a chave e os segredos abertos nesta sessão
USAGE
}

host_file() {
  local host="${1:-${DEFAULT_HOST}}"
  if [ -z "${host}" ]; then
    echo "Informe o host, ex.: secrets $2 fedora-laptop" >&2
    exit 1
  fi
  echo "${repo}/secrets/${host}.yaml"
}

# O sops sai com 200 quando o arquivo não mudou; isso não é erro.
sops_edit() {
  local rc=0
  (cd "${repo}" && sops edit "$1") || rc=$?
  [ "${rc}" -eq 0 ] || [ "${rc}" -eq 200 ] || exit "${rc}"
}

reload() {
  if systemctl --user cat sops-nix.service >/dev/null 2>&1; then
    systemctl --user restart sops-nix.service && echo "Segredos abertos em ~/.config/sops-nix/secrets."
  else
    echo "Rode \`just switch\` para ligar os segredos neste host."
  fi
}

cmd_init() {
  local file pub
  file="$(host_file "${1:-}" init)"
  if [ ! -f "${key_file}" ]; then
    mkdir -p "$(dirname "${key_file}")"
    age-keygen -o "${key_file}" 2>/dev/null
    chmod 600 "${key_file}"
    echo "Chave nova em ${key_file}."
  fi
  pub="$(age-keygen -y "${key_file}")"

  if [ ! -f "${repo}/.sops.yaml" ]; then
    cat >"${repo}/.sops.yaml" <<EOF
# Quem pode abrir os segredos (secrets/*.yaml). Uma chave age pública por linha; docs/secrets.md.
creation_rules:
  - path_regex: secrets/[^/]+\.yaml\$
    age: >-
      ${pub}
EOF
    echo "Criado ${repo}/.sops.yaml com a sua chave pública."
  elif ! grep -q "${pub}" "${repo}/.sops.yaml"; then
    echo "Aviso: a sua chave pública não está no .sops.yaml. Acrescente (separada por vírgula) e rode"
    echo "  sops updatekeys ${file}"
    echo "  ${pub}"
  fi

  if [ ! -f "${file}" ]; then
    mkdir -p "$(dirname "${file}")"
    local tmp
    tmp="$(mktemp)"
    trap 'rm -f "${tmp}"' RETURN
    cat >"${tmp}" <<EOF
# Troque pelos seus dados. Tokens: acrescente em env: e liste o nome em devenv.secrets.env no host.
git:
  name: $(git config --global user.name 2>/dev/null || echo "Seu Nome")
  email: voce@exemplo.com
EOF
    local rel
    rel="secrets/$(basename "${file}")"
    # shellcheck disable=SC2094 # --filename-override só escolhe a regra do .sops.yaml; o arquivo não é lido
    (cd "${repo}" && sops encrypt --filename-override "${rel}" \
      --input-type yaml --output-type yaml "${tmp}" >"${rel}")
    echo "Criado ${file} (cifrado). Abrindo para você preencher..."
    sops_edit "${file}"
  fi

  cat <<EOF

Falta guardar a chave no Bitwarden, para restaurar em outra máquina:
  rbw add ${bw_item}      (cole como senha a linha AGE-SECRET-KEY-... de ${key_file})
Depois: git add .sops.yaml secrets/ && just switch
EOF
}

cmd_edit() {
  local file
  file="$(host_file "${1:-}" edit)"
  [ -f "${file}" ] || {
    echo "${file} não existe. Rode: secrets init" >&2
    exit 1
  }
  sops_edit "${file}"
  reload
}

cmd_restore() {
  if [ -f "${key_file}" ]; then
    echo "Já existe uma chave em ${key_file}. Nada a fazer."
    reload
    return
  fi
  rbw unlock
  rbw sync
  local secret
  secret="$(rbw get "${bw_item}")"
  case "${secret}" in
    AGE-SECRET-KEY-*) ;;
    *)
      echo "A senha do item ${bw_item} no Bitwarden não é uma chave age (AGE-SECRET-KEY-...)." >&2
      exit 1
      ;;
  esac
  mkdir -p "$(dirname "${key_file}")"
  (umask 077 && printf '%s\n' "${secret}" >"${key_file}")
  echo "Chave restaurada em ${key_file}."
  reload
}

cmd_status() {
  if [ -f "${key_file}" ]; then
    echo "chave:     ${key_file} ($(age-keygen -y "${key_file}"))"
  else
    echo "chave:     não encontrada (secrets restore ou secrets init)"
  fi
  echo "serviço:   $(systemctl --user is-active sops-nix.service 2>/dev/null || true)"
  local dir="${XDG_CONFIG_HOME:-${HOME}/.config}/sops-nix/secrets"
  if [ -d "${dir}" ]; then
    echo "segredos:"
    (cd "${dir}" && find -L . -type f ! -path './rendered/*' | sed 's|^\./|  |' | sort)
  fi
}

case "${1:-}" in
  init) cmd_init "${2:-}" ;;
  edit) cmd_edit "${2:-}" ;;
  restore) cmd_restore ;;
  status) cmd_status ;;
  -h | --help | help | "") usage ;;
  *)
    usage >&2
    exit 1
    ;;
esac
