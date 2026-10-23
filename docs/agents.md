# Agentes de código

Quatro agentes instalados pelo Nix e configurados a partir de [`agents/`](../agents/):
**Claude Code** (principal, assinatura Pro), **Codex**, **Gemini CLI** e **opencode**.
O módulo é [`modules/agents`](../modules/agents/default.nix) (`devenv.agents.enable`).

## Primeiro uso

Depois do `just switch`, faça login uma vez em cada agente que for usar:

| Agente | Comando | Login |
| --- | --- | --- |
| Claude Code | `claude` (ou `cc`) | conta Claude (assinatura Pro, sem chave de API) |
| Codex | `codex` | conta ChatGPT ou chave da OpenAI |
| Gemini CLI | `gemini` | conta Google (cota gratuita) |
| opencode | `opencode` | `/connect` dentro dele; com modelos locais, nenhum |

Segredos (chaves de API, tokens) vêm do Bitwarden: `rbw config set email <seu e-mail>`,
`rbw login` e depois `rbw get <nome>`. Os que o ambiente precisa sempre (ex.: `HF_TOKEN`) podem ficar cifrados em
`secrets/` ([secrets.md](secrets.md)). Nunca em texto puro no repo.

## Como a configuração funciona

| O quê | Fonte no repo | Onde fica |
| --- | --- | --- |
| Instruções globais | `agents/AGENTS.md` | `~/.config/agents/AGENTS.md`, ligado em `~/.codex`, `~/.gemini`, `~/.config/opencode`; o `~/.claude/CLAUDE.md` importa |
| Skills | `agents/skills/` + as do workmux | `~/.agents/skills` (Codex, Gemini, opencode) e `~/.claude/skills` |
| Configs dos agentes | `modules/agents/default.nix` (`managed`) | mescladas em cada arquivo a cada switch |
| Statusline do Claude | `agents/statusline.sh` | `statusLine` no `~/.claude/settings.json` |
| workmux | `modules/agents/workmux.yaml` | cópia editável em `~/.config/workmux/config.yaml` |

`AGENTS.md` e as nossas skills são links para o repo: editar o arquivo muda o agente na hora, sem switch.

Os agentes também escrevem nos próprios arquivos de config (login, pastas confiáveis, preferências).
Por isso o devenv **não** troca esses arquivos por links somente leitura: a cada switch, o
[`merge-config.py`](../agents/merge-config.py) mescla só as chaves que o devenv gerencia e deixa o resto.
Uma chave gerenciada que você mudar na mão volta ao valor do repo no próximo switch; para mudar de vez, mude no módulo.

Chaves gerenciadas:

- **Claude Code** (`~/.claude/settings.json`): sem atualização automática (quem atualiza é o Nix), statusline, sandbox, `teammateMode`, hooks do workmux. Em `~/.claude.json`: os MCPs.
- **Codex** (`~/.codex/config.toml`): `sandbox_mode = "workspace-write"`, `approval_policy = "on-request"`, sem telemetria, hooks do workmux, MCPs.
- **Gemini CLI** (`~/.gemini/settings.json`): lê `AGENTS.md`, sem atualização automática e sem estatísticas, skills, MCPs, hooks do workmux.
- **opencode** (`~/.config/opencode/opencode.json`): sem atualização automática, MCPs, provedor Ollama quando os modelos locais estão ligados.

## Versões e atualização

Os binários vêm do [llm-agents.nix](https://github.com/numtide/llm-agents.nix) (numtide), atualizado todo dia,
com cache binário em `cache.numtide.com` (já configurado no flake, no bootstrap e no CI).

```bash
just agents-update   # só o llm-agents no flake.lock
just switch
```

A atualização semanal do `flake.lock` (PR automático) também os atualiza.

## Roteamento: quem faz o quê

A tabela fica no [`AGENTS.md`](../agents/AGENTS.md), então todo agente a conhece. Resumo:

| Tarefa | Agente |
| --- | --- |
| Planejar, refatoração grande | Claude Code com Opus (plan mode) |
| Implementar e testar | Claude Code com Sonnet |
| Buscar no código, ler logs | subagente Explore do Claude (Haiku) |
| Revisão independente de um diff | Codex (`codex exec`) |
| Muito contexto | Gemini CLI (`gemini -p`) |
| Modelos abertos ou locais | opencode |

Skills que usam a tabela:

- **`/route <tarefa>`**: classifica e manda para o agente certo; tarefas longas viram um worktree no workmux.
- **`/second-opinion`**: pede revisão do diff ao Codex e/ou Gemini, só leitura, e junta as respostas.

Por que assim: a cota do Pro é o recurso escasso, e o roteamento por instrução não precisa de proxy nem de chave de API.

## Trabalho em paralelo: workmux

Uma tarefa = um branch + um git worktree + uma janela do tmux com o agente e um shell embaixo.

| Comando | Abreviação | O que faz |
| --- | --- | --- |
| `workmux add <nome> -p "<pedido>"` | `wa` | cria worktree e janela, já com o pedido |
| `workmux add <nome> -a codex` | | o mesmo com outro agente (`claude`, `codex`, `gemini`, `opencode`) |
| `workmux dashboard` | `wd`, prefixo + `a` | painel com todas as tarefas e o status de cada agente |
| `workmux merge` | `wm` | junta o branch (rebase) e remove o worktree |

O ícone na janela do tmux mostra o estado do agente: 🤖 trabalhando, 💬 esperando você, ✅ pronto.
Funciona nos quatro agentes (hooks no Claude, Gemini e Codex; plugin no opencode).
Skills do workmux também instaladas: `/workmux`, `/worktree`, `/coordinator`, `/merge`, `/rebase`, `/open-pr`.

## Agent teams do Claude

Ficam desligadas (experimentais e gastam cota rápido). Para uma sessão: `cteam` (o mesmo que
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude`). Dentro do tmux, cada colega abre num painel (`teammateMode = "auto"`).

## Uso, custo e modelo

- **Statusline do Claude**: modelo │ contexto % │ cota de 5 h (tempo até renovar) │ cota da semana │ custo │ branch.
  Verde abaixo de 50 %, amarelo até 80 %, vermelho acima. O custo é o equivalente na API, só referência.
- **Barra do tmux**: a cota do Claude (`5h 42% 7d 12%`), atualizada pela statusline.
- **tokscale** (`usage` ou prefixo + `u`): histórico de tokens e custo por agente, modelo e dia, lendo os logs locais dos quatro.
- **workmux dashboard**: o que cada agente está fazendo agora.
- OpenTelemetry (Claude Code e Codex exportam métricas) fica para quando houver um coletor; não vem ligado.

## Documentação de bibliotecas (MCP)

Os quatro agentes têm dois servidores MCP:

- **`context7`**: documentação atualizada e por versão das bibliotecas populares (remoto, gratuito).
- **`docs`**: índice local ([docs-mcp-server](https://github.com/arabold/docs-mcp-server)) para o que o context7 não tem ou docs internas.

```bash
docs-mcp scrape polars https://docs.pola.rs/api/python/stable/   # indexa uma vez
docs-mcp search polars "lazy join"                               # busca pela CLI
docs-mcp list
```

O índice fica em `~/.local/share/docs-mcp`. Roda por `npx` (versão fixada em `devenv.agents.docsMcpVersion`), baixado só no primeiro uso.

## Sandbox

O Claude Code roda os comandos de shell no sandbox nativo (bubblewrap): escrita só na pasta do projeto,
rede controlada. Com isso, comandos dentro do sandbox não pedem permissão (`autoAllowBashIfSandboxed`).
O Codex usa o sandbox dele (`workspace-write`). O bootstrap instala `bubblewrap` e `socat` pela distro;
no Ubuntu 24.04+ também cria o perfil do AppArmor que o bubblewrap precisa.

Para desligar: `devenv.agents.sandbox = false;` no host.

## Modelos locais (Ollama)

Desligado por padrão. Para ligar, no host:

```nix
devenv.localModels = {
  enable = true;
  acceleration = "cuda";             # NVIDIA; "rocm" para AMD, null para só CPU
  models = [ "qwen3-coder:30b" ];    # baixados no primeiro start
};
```

O serviço **não** sobe no login (não gasta memória à toa): `ollama-on` e `ollama-off` ligam e desligam.
`autoStart = true` muda isso. Com ele ligado, o opencode ganha o provedor `Ollama (local)`.

## Arquivos

```text
agents/
  AGENTS.md            instruções globais (fonte única)
  skills/              route, second-opinion
  statusline.sh        statusline do Claude Code
  merge-config.py      mescla as chaves gerenciadas nas configs dos agentes
modules/agents/        módulo Nix: pacotes, configs, links, abreviações
modules/agents/workmux.yaml
modules/local-models/  Ollama opcional
```
