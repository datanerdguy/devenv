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
check "neovim instalado pelo bob" "${HOME}/.local/share/bob/nvim-bin/nvim" --version
check "config do neovim ligada ao repo" test -f "${HOME}/.config/nvim/init.lua"
for bin in lua-language-server basedpyright ruff gopls nixd tree-sitter stylua; do
  check "ferramenta ${bin}" command -v "${bin}"
done
check "direnv com nix-direnv" test -f "${HOME}/.config/direnv/lib/hm-nix-direnv.sh"

# Agentes e tmux
for bin in claude codex gemini opencode workmux tokscale docs-mcp tmux sesh; do
  check "binário ${bin}" command -v "${bin}"
done
# O tmux sai com 0 mesmo com erro na config; o erro aparece na saída.
# shellcheck disable=SC2329 # chamada pelo check
tmux_config_ok() {
  local out
  out="$(tmux -L smoke -f /dev/null new-session -d \; source-file "${HOME}/.config/tmux/tmux.conf" \; kill-server 2>&1)"
  [ -z "${out}" ]
}
check "tmux carrega a config sem erro" tmux_config_ok
for f in .claude/settings.json .claude.json .gemini/settings.json .config/opencode/opencode.json; do
  check "config ${f} é JSON válido" jq -e . "${HOME}/${f}"
done
check "config do codex é TOML válido" taplo check --no-schema "${HOME}/.codex/config.toml"
check "statusline do claude configurada" jq -e '.statusLine.command' "${HOME}/.claude/settings.json"
check "MCPs context7 e docs no claude" jq -e '.mcpServers.context7 and .mcpServers.docs' "${HOME}/.claude.json"
for f in .config/agents/AGENTS.md .codex/AGENTS.md .gemini/AGENTS.md .config/opencode/AGENTS.md .claude/CLAUDE.md; do
  check "instruções ${f}" test -s "${HOME}/${f}"
done
for s in route second-opinion workmux merge; do
  check "skill ${s}" test -f "${HOME}/.agents/skills/${s}/SKILL.md"
  check "skill ${s} no claude" test -f "${HOME}/.claude/skills/${s}/SKILL.md"
done
check "config do workmux" test -f "${HOME}/.config/workmux/config.yaml"

# Neovim: instala os plugins, carrega todos e mede a abertura.
export PATH="${HOME}/.local/share/bob/nvim-bin:${PATH}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log="$(mktemp)"
if DEVENV_NVIM_TEST=1 nvim --headless -l "${repo_dir}/tests/nvim/check.lua" >"${log}" 2>&1; then
  echo "ok    neovim carrega todos os plugins"
else
  echo "FALHA neovim carrega todos os plugins"
  fail=1
fi
grep -v '^vim.pack' "${log}" || true
if "${repo_dir}/tests/nvim/startup.sh"; then
  echo "ok    neovim abre dentro do limite"
else
  echo "FALHA neovim abre dentro do limite"
  fail=1
fi

exit "${fail}"
