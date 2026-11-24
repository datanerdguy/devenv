# Agentes e git

## Onde fica cada coisa

| No repo | Na máquina | Como |
| --- | --- | --- |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md` | link |
| `agents/pstack-models.md` | `~/.claude/pstack-models.md` | link |
| `agents/statusline.sh` | `~/.claude/statusline.sh` | link |
| `agents/settings.json` | `~/.claude/settings.json` | mesclado no `just apply` |
| `agents/mcp.json` | `~/.claude.json` | mesclado no `just apply` |
| `home/dot_config/git/` | `~/.config/git/config` e `ignore` | link |
| `home/dot_config/lazygit/` | `~/.config/lazygit/config.yml` | link |

Os pacotes ficam nos grupos `agents` (claude-code, bubblewrap, socat) e `git` (git-delta, lazygit).

## Claude Code

- **Mudar o settings:** edite `agents/settings.json` e rode `just apply`. O que não está nesse arquivo (o tema,
  por exemplo) continua do jeito que o Claude deixou.
- **Modelo:** Sonnet abre por padrão. `/model opus` troca na sessão.
- **Modelos do pstack:** edite `agents/pstack-models.md`. Não rode o `/setup-pstack`, porque ele sobrescreve o arquivo
  e mexe no `CLAUDE.md`.
- **Statusline:** mostra modelo, contexto usado, cota de 5h (com o tempo até zerar), cota de 7 dias, custo
  equivalente na API e branch. Verde abaixo de 50%, amarelo abaixo de 80%, vermelho acima. A cota também vai
  para `~/.cache/devenv/claude-usage`, para a barra do tmux.
- **workmux:** os hooks em `agents/settings.json` mostram na janela do tmux se o agente está trabalhando, esperando
  ou terminou. Fora do tmux eles não fazem nada. Veja [tmux.md](tmux.md).
- **Sandbox:** o Bash do Claude escreve só no projeto e acessa só os domínios de `sandbox.network.allowedDomains`.
  Para liberar um domínio, adicione-o lá. Os caches das linguagens (uv, Go, cargo, npm) também são graváveis,
  em `sandbox.filesystem.allowWrite`. As pastas das toolchains (`~/.rustup`, mise, `~/go/bin`, `~/.cargo/bin`)
  não: instalar uma toolchain pede permissão, porque um binário trocado ali rodaria fora do sandbox. O sandbox
  só libera pasta que já existe, então o `bootstrap.sh` cria vazias as que faltam (`~/.cache/go-build` e afins).
- **MCP:** `context7`, para a documentação de bibliotecas na versão do projeto.

## Git

- `git diff`, `git log -p` e `git show` passam pelo delta (navegue entre arquivos com `n` e `N`).
- `lazygit` abre a interface no repo atual, com o delta nos diffs.
- `git wt` é `git worktree`; `git last` mostra o último commit.
- O login no GitHub é o do `gh` (`gh auth login`), por HTTPS.

## Por que assim

- O settings é mesclado, não ligado: o Claude grava nele (tema, plugins), e um link o faria escrever no repo.
- O `claude-code` vem do pacman, com o auto-update desligado: só o sistema atualiza.
- O pstack não usa Fable em nenhum papel, para poupar a cota do Pro.
- Só o MCP `context7`: é remoto e não pede chave.
- Nome e email do git ficam em texto: o email é o noreply do GitHub, já público em cada commit. Commits sem
  assinatura, para não ter mais uma chave para guardar.
