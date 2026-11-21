#!/usr/bin/env bash
# Confere o que o bootstrap deve deixar pronto. Roda no CI depois do ./bootstrap.sh.
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

# check <o que> <comando...>: imprime ok ou FALTA e marca a falha.
check() {
  local what="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "ok: ${what}"
  else
    echo "FALTA: ${what}" >&2
    fail=1
  fi
}

for cmd in chezmoi metapac just cz; do
  check "${cmd} no PATH" command -v "${cmd}"
done
check "${HOME}/.config/metapac -> ${repo}/packages" test "$(readlink -f "${HOME}/.config/metapac")" = "${repo}/packages"
check "asm-lsp em ${HOME}/.local/bin (chezmoi)" test -x "${HOME}/.local/bin/asm-lsp"
check "rustup com rustc e rust-analyzer" rustup which rust-analyzer

# Com o grupo terminal.
if command -v ghostty >/dev/null; then
  check "config do Ghostty" ghostty +validate-config --config-file="${HOME}/.config/ghostty/config"
  # Sem pipe direto: com pipefail, o grep -q sai cedo e o fc-list morre de SIGPIPE, o que conta como falha.
  fonts="$(fc-list : family)"
  check "fonte BlexMono Nerd Font" grep -q "BlexMono Nerd Font" <<<"${fonts}"
fi

# Com o grupo editor: o hook do bob deixou o nightly em uso.
if command -v bob >/dev/null; then
  check "Neovim nightly pelo bob" test -x "${HOME}/.local/share/bob/nvim-bin/nvim"
fi

# Agentes: instruções, settings mesclado, statusline e MCP.
check "${HOME}/.claude/CLAUDE.md -> agents/AGENTS.md" test "$(readlink -f "${HOME}/.claude/CLAUDE.md")" = "${repo}/agents/AGENTS.md"
check "settings do Claude com sandbox e statusline" jq -e '.sandbox.enabled and .statusLine.command' "${HOME}/.claude/settings.json"
check "MCP context7 no ~/.claude.json" jq -e '.mcpServers.context7.url' "${HOME}/.claude.json"
check "${HOME}/.claude.json só para o dono (0600)" test "$(stat -c %a "${HOME}/.claude.json")" = 600
check "statusline roda" bash "${HOME}/.claude/statusline.sh" <<<'{"model":{"display_name":"Sonnet"}}'

# Git.
check "git com o delta de pager" test "$(git config --get core.pager)" = delta
if command -v lazygit >/dev/null; then
  check "delta e lazygit instalados" command -v delta
fi

exit "${fail}"
