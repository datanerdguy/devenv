#!/usr/bin/env bash
# Põe o devenv de pé numa máquina nova: ./bootstrap.sh
# Arch e derivadas (CachyOS, EndeavourOS...). Pode rodar de novo: o resultado é o mesmo.
# Com CI definido (como no GitHub Actions), não pergunta nada.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
key="${HOME}/.config/chezmoi/key.txt"
yes_flag=()
if [ -n "${CI:-}" ]; then yes_flag=(--noconfirm); fi

say() { printf '==> %s\n' "$*"; }

if [ "${EUID}" -eq 0 ]; then
  echo "Rode como seu usuário, não como root: o makepkg e o paru recusam o root." >&2
  exit 1
fi

# 1. Só Arch e derivadas.
# shellcheck disable=SC1091
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
  *" arch "*) ;;
  *)
    echo "Este bootstrap é para Arch e derivadas; esta máquina é '${ID:-desconhecida}'." >&2
    exit 1
    ;;
esac

# 2. paru: no CachyOS já vem; senão compila o paru-bin do AUR.
if ! command -v paru >/dev/null; then
  say "Instalando o paru (AUR)"
  sudo pacman -S --needed "${yes_flag[@]}" base-devel git
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/paru-bin.git "${tmp}/paru-bin"
  (cd "${tmp}/paru-bin" && makepkg -si --needed "${yes_flag[@]}")
  rm -rf "${tmp}"
fi

# 3. O mínimo para o resto. O rustup vem antes: ele dá o cargo que compila o metapac do AUR.
# Sem isso, o paru instala o pacote rust, que conflita com o rustup do grupo base.
say "Instalando rustup, chezmoi, metapac, age e rbw"
paru -S --needed "${yes_flag[@]}" rustup
rustup default stable
paru -S --needed "${yes_flag[@]}" chezmoi metapac age rbw

# 4. Chave age: traz do Bitwarden se faltar. Sem rbw logado, segue sem ela.
if [ ! -f "${key}" ]; then
  say "Buscando a chave age no Bitwarden (item devenv-age-key)"
  mkdir -p "$(dirname "${key}")"
  tmp_key="$(umask 077 && mktemp "${key}.XXXXXX")"
  if rbw get devenv-age-key >"${tmp_key}" 2>/dev/null && [ -s "${tmp_key}" ]; then
    mv "${tmp_key}" "${key}"
  else
    rm -f "${tmp_key}"
    echo "Aviso: rbw não está logado, ou o item não existe. Sem a chave age, segredos cifrados ficam de fora." >&2
    echo "Depois: rbw login, rbw get devenv-age-key > ${key} (chmod 600) e ./bootstrap.sh de novo." >&2
  fi
fi

# 5. Configs: links para o repo.
say "Aplicando as configs (chezmoi)"
chezmoi init --source "${repo}" --apply

# 6. Pacotes. O metapac sempre sincroniza nesta ordem: arch, cargo, mise, uv.
# Assim rustup, mise e uv já estão no lugar quando os outros backends rodam.
say "Sincronizando os pacotes (metapac)"
if [ -n "${CI:-}" ]; then
  metapac sync --no-confirm
elif [ ! -t 0 ] || [ ! -t 1 ]; then
  # O metapac pergunta antes de instalar e precisa de um terminal (sem pipe, como `| tee`).
  echo "O metapac precisa de um terminal para perguntar. Rode sem pipe: just sync" >&2
  exit 1
else
  metapac sync
fi
say "Pronto"
