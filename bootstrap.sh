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

# O metapac pergunta antes de instalar: sem terminal (com pipe, como `| tee`), ele falha no meio. Melhor parar antes.
if [ -z "${CI:-}" ] && { [ ! -t 0 ] || [ ! -t 1 ]; }; then
  echo "Rode num terminal, sem pipe: ./bootstrap.sh" >&2
  exit 1
fi

# Cada máquina precisa da sua entrada em packages/config.toml; sem ela, o metapac não sabe o que instalar.
host="$(cat /etc/hostname 2>/dev/null || uname -n)"
if ! grep -q "^${host} = " "${repo}/packages/config.toml"; then
  echo "A máquina '${host}' não está em [hostname_groups] de packages/config.toml. Acrescente uma linha para ela." >&2
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
  sudo pacman -Syu --needed "${yes_flag[@]}" base-devel git
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/paru-bin.git "${tmp}/paru-bin"
  (cd "${tmp}/paru-bin" && makepkg -si --needed "${yes_flag[@]}")
  rm -rf "${tmp}"
fi

# 3. O mínimo para o resto. O rustup vem antes: ele dá o cargo que compila o metapac do AUR.
# Sem isso, o paru instala o pacote rust, que conflita com o rustup do grupo base.
# O jq também vem antes: os modify_ do chezmoi (settings do Claude) usam ele no apply.
say "Instalando rustup, chezmoi, metapac, age, rbw e jq"
# Antes de tudo, o sistema em dia: com o banco de pacotes velho, o espelho pode já não ter a versão pedida (404).
# No Arch é sempre -Syu, nunca só -Sy: atualizar o banco sem os pacotes deixa o sistema pela metade.
paru -Syu --needed "${yes_flag[@]}" rustup
rustup default stable
paru -S --needed "${yes_flag[@]}" chezmoi metapac age rbw jq

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
else
  metapac sync
fi
# O metapac marca as dependências como explícitas; aqui elas voltam a ser dependências.
"${repo}/packages/marca-deps.sh"
say "Pronto"
