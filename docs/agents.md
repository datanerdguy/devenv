# Agentes de código

O agente é o **Claude Code** (assinatura Pro, sem chave de API), instalado pelo Nix e configurado a partir de
[`agents/`](../agents/). Junto vêm o workmux (tarefas em paralelo), o tokscale (uso) e os MCPs de documentação.
O módulo é [`modules/agents`](../modules/agents/default.nix) (`devenv.agents.enable`).

Codex, Gemini CLI e opencode saíram em 2026-11 (ADR 0003, atualização): o roteamento usa só modelos do Claude Code.

## Primeiro uso

Depois do `just switch`, rode `claude` (ou `cc`) e faça login com a conta Claude.

Segredos (chaves de API, tokens) vêm do Bitwarden: `rbw config set email <seu e-mail>`,
`rbw login` e depois `rbw get <nome>`. Os que o ambiente precisa sempre (ex.: `HF_TOKEN`) podem ficar cifrados em
`secrets/` ([secrets.md](secrets.md)). Nunca em texto puro no repo.

## Como a configuração funciona

| O quê | Fonte no repo | Onde fica |
| --- | --- | --- |
| Instruções globais | `agents/AGENTS.md` | `~/.config/agents/AGENTS.md`; o `~/.claude/CLAUDE.md` importa |
| Skills | `agents/skills/` + as do workmux | `~/.claude/skills` |
| Configs do Claude | `modules/agents/default.nix` (`managed`) | mescladas em cada arquivo a cada switch |
| Statusline do Claude | `agents/statusline.sh` | `statusLine` no `~/.claude/settings.json` |
| workmux | `modules/agents/workmux.yaml` | cópia editável em `~/.config/workmux/config.yaml` |

`AGENTS.md` e as nossas skills são links para o repo: editar o arquivo muda o agente na hora, sem switch.

O Claude também escreve nos próprios arquivos de config (login, pastas confiáveis, preferências).
Por isso o devenv **não** troca esses arquivos por links somente leitura: a cada switch, o
[`merge-config.py`](../agents/merge-config.py) mescla só as chaves que o devenv gerencia e deixa o resto.
Uma chave gerenciada que você mudar na mão volta ao valor do repo no próximo switch; para mudar de vez, mude no módulo.

Chaves gerenciadas:

- `~/.claude/settings.json`: sem atualização automática (quem atualiza é o Nix), statusline, sandbox, modelo padrão, `teammateMode`, hooks do workmux.
- `~/.claude.json`: os MCPs.

## Versões e atualização

O Claude Code, o workmux e o tokscale vêm do [llm-agents.nix](https://github.com/numtide/llm-agents.nix) (numtide), atualizado todo dia,
com cache binário em `cache.numtide.com` (já configurado no flake, no bootstrap e no CI).

```bash
just agents-update   # só o llm-agents no flake.lock
just switch
```

O `just update` (o `flake.lock` inteiro) também os atualiza.

## Roteamento: quem faz o quê

As regras ficam no [`AGENTS.md`](../agents/AGENTS.md). O roteamento usa só o que
o Claude Code oferece: modelo (`haiku`, `sonnet`, `opus`, `opusplan`), effort e subagentes.

### Modelos e effort do Claude

No Pro entram Haiku 5.5, Sonnet 5.5 e Opus 5.5. O Fable 5.1 fica de fora: no Pro ele é cobrado em créditos
à parte ([suporte](https://support.claude.com/en/articles/15424964-claude-fable-models-on-your-plan)), então o AGENTS.md proíbe usar sem pedido.

| Uso | Modelo | Effort |
| --- | --- | --- |
| Busca, leitura de logs, resumo, commit, boilerplate, classificação | Haiku (em subagente) | low a medium |
| Código do dia a dia: bug localizado, feature, testes, CI, SQL e análise | Sonnet | medium a high |
| Bug difícil | Sonnet `xhigh`, depois Opus | xhigh / high |
| Plano, arquitetura, refatoração grande, desenho de ML, segurança | Opus (plan mode ou `opusplan`) | high a xhigh |
| Revisão de diff | Sonnet (rotina) ou Opus (risco), num subagente com contexto limpo | medium / high |

A tabela completa (16 tipos de tarefa) fica na skill [`route`](../agents/skills/route/SKILL.md), que só carrega quando é usada; o AGENTS.md guarda as regras curtas, inclusive as de subagente. Em resumo, subagente
serve para busca ampla, partes independentes em paralelo (até 3) e revisão com contexto limpo, sempre com o
modelo explícito, porque sem isso ele herda o da sessão.

Por que essa divisão (números da Anthropic, outubro de 2026):

| Benchmark | Opus 5.5 | Sonnet 5.5 | Haiku 5.5 |
| --- | --- | --- | --- |
| SWE-bench Pro | 89,9% | 81,3% | 64,8% |
| Terminal-Bench 4.0 | 66,4% (xhigh) | 70,6% | 39,2% (max) |
| FrontierCode 1.1 | 54,4% (max) | 52,1% (xhigh), 46,2% (max) | 46,4% (max) |
| Preço da API por milhão de tokens (entrada/saída), para comparar o gasto de cota | $4 / $20 | $2 / $10 | $0,10 / $0,50 |

- O Sonnet empata ou passa o Opus em tarefas de terminal e bem definidas, pela metade do custo. O Opus ganha em
  código grande e aberto (SWE-bench Pro) e em trabalho longo que pede julgamento.
- Effort pesa quase tanto quanto o modelo: o Opus em `medium` fica perto do Fable em `max` (CursorBench 52,5% contra 51,8%).
  O Haiku sobe de 53% (`medium`) para 61% (`high`) e 72% (`max`) no OSWorld, mas o `max` custa 3 a 4 vezes mais.
- `max` nem sempre ganha: o Sonnet rende mais em `xhigh` do que em `max` no FrontierCode.
- O padrão do Claude Code no Pro seria Opus 5.5. O devenv põe **Sonnet** (`devenv.agents.claudeModel`, padrão `"sonnet"`)
  para poupar cota; `/model opus` ou `/model opusplan` quando a tabela pedir.

Fontes: [configuração de modelos](https://code.claude.com/docs/en/model-config),
[comparação dos três](https://www.developersdigest.tech/blog/claude-opus-5-5-vs-sonnet-5-5-vs-haiku-5-5),
[SWE-bench Pro](https://codingfleet.com/blog/swe-bench-pro-leaderboard-2026/),
[Haiku 5.5](https://apidog.com/blog/claude-haiku-5-5-benchmarks/), [Opus 5.5 e Fable 5.1](https://www.morphllm.com/claude-code-models).

Skills:

- **`/route <tarefa>`**: escolhe modelo, effort e se roda na sessão, num subagente ou num worktree do workmux.
- **`/nvim-lua`**: regras para escrever e revisar o Lua do Neovim, com o `check-api.sh` (APIs removidas ou deprecadas), o teste de carga e a medida da abertura como portões.
- **`/second-opinion`**: revisão por um subagente com outro modelo do Claude (Sonnet escreveu, Opus revisa; Opus escreveu, Sonnet revisa), contexto limpo e só leitura.

Por que assim: a cota do Pro é o recurso escasso, e o roteamento por instrução não precisa de proxy nem de chave de API.

## Trabalho em paralelo: workmux

Uma tarefa = um branch + um git worktree + uma janela do tmux com o agente e um shell embaixo.

| Comando | Abreviação | O que faz |
| --- | --- | --- |
| `workmux add <nome> -p "<pedido>"` | `wa` | cria worktree e janela, já com o pedido |
| `workmux dashboard` | `wd`, prefixo + `a` | painel com todas as tarefas e o status de cada agente |
| `workmux merge` | `wm` | junta o branch (rebase) e remove o worktree |

O ícone na janela do tmux mostra o estado do agente: 🤖 trabalhando, 💬 esperando você, ✅ pronto.
Vem dos hooks do Claude Code.
Skills do workmux também instaladas: `/workmux`, `/worktree`, `/coordinator`, `/merge`, `/rebase`, `/open-pr`.

## Agent teams do Claude

Ficam desligadas (experimentais e gastam cota rápido). Para uma sessão: `cteam` (o mesmo que
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude`). Dentro do tmux, cada colega abre num painel (`teammateMode = "auto"`).

## Uso, custo e modelo

- **Statusline do Claude**: modelo │ contexto % │ cota de 5 h (tempo até renovar) │ cota da semana │ custo │ branch.
  Verde abaixo de 50 %, amarelo até 80 %, vermelho acima. O custo é o equivalente na API, só referência.
- **Barra do tmux**: a cota do Claude (`5h 42% 7d 12%`), atualizada pela statusline.
- **tokscale** (`usage` ou prefixo + `u`): histórico de tokens e custo por modelo e dia, lendo os logs locais do Claude.
- **workmux dashboard**: o que cada agente está fazendo agora.
- OpenTelemetry (o Claude Code exporta métricas) fica para quando houver um coletor; não vem ligado.

## Documentação de bibliotecas (MCP)

O Claude tem dois servidores MCP:

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
O bootstrap instala `bubblewrap` e `socat` pela distro;
no Ubuntu 24.04+ também cria o perfil do AppArmor que o bubblewrap precisa.

Para desligar: `devenv.agents.sandbox = false;` no host.

## Modelos locais (Ollama)

Desligado por padrão. Para ligar, no host:

```nix
devenv.localModels = {
  enable = true;
  acceleration = "cuda";             # NVIDIA; "rocm" para AMD, null para só CPU
};
```

O serviço **não** sobe no login (não gasta memória à toa): `ollama-on` e `ollama-off` ligam e desligam.
`autoStart = true` muda isso. Nenhum agente usa os modelos locais: baixe com `ollama pull <modelo>` e use direto (`ollama run`).

## Arquivos

```text
agents/
  AGENTS.md            instruções globais (fonte única)
  skills/              route, second-opinion, nvim-lua
  statusline.sh        statusline do Claude Code
  merge-config.py      mescla as chaves gerenciadas nas configs do Claude
modules/agents/        módulo Nix: pacotes, configs, links, abreviações
modules/agents/workmux.yaml
modules/local-models/  Ollama opcional
```
