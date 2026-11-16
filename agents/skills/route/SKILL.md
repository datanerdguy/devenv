---
name: route
description: Escolhe o modelo, o effort e o jeito de rodar (sessão, subagente ou worktree) de uma tarefa no Claude Code. Use ao planejar trabalho em paralelo, ao distribuir tarefas, ou ao escolher modelo ou effort para uma tarefa ou subagente.
---

# Rotear uma tarefa

Só opções do Claude Code: modelos `haiku`, `sonnet`, `opus` e `opusplan`; effort `low`, `medium`, `high`,
`xhigh` e `max`; subagentes `Explore`, `Plan` e `general-purpose`. Fable fica de fora (não entra no Pro).

1. Classifique a tarefa pela tabela abaixo: modelo, effort e como rodar.
2. Na sessão: se o modelo da tabela for outro, sugira `/model <modelo>` e `/effort <nível>` antes de começar.
3. Em subagente: passe `model` e `effort` explícitos, senão ele herda os da sessão.
4. Tarefa longa ou várias independentes: uma por worktree,
   `workmux add <nome-curto> -a claude -p "<pedido completo>"`, no máximo 3 ao mesmo tempo,
   e diga ao usuário onde estão rodando (`workmux dashboard`).
5. Ao terminar, resuma o que cada parte fez e o que falta.

## Modelo e effort por tarefa

| Tarefa | Modelo | Effort | Como |
| --- | --- | --- | --- |
| Achar onde algo está, mapear um módulo, ler logs ou saída longa | Haiku | low | subagente Explore |
| Commit, changelog, renomear, formatar, boilerplate, docstrings | Haiku | low | subagente ou sessão em Haiku |
| Resumir doc ou thread, extrair ou classificar dados, triagem de issues | Haiku | medium | subagente |
| Pergunta rápida, explicar um trecho, comando de shell | Sonnet | low | na sessão |
| Bug localizado, teste unitário, feature pequena com escopo claro | Sonnet | medium | na sessão |
| Feature em vários arquivos, refatorar um módulo, testes de integração | Sonnet | high | na sessão; partes independentes em subagentes Sonnet |
| CI quebrado, erro de Nix, build, dependências | Sonnet | high | na sessão; logs longos vão para um subagente Haiku |
| SQL, pandas/polars, análise exploratória, notebook | Sonnet | medium | na sessão |
| Bug difícil (intermitente, concorrência, sem pista clara) | Sonnet → Opus | xhigh → high | se o Sonnet errar duas vezes, passe para o Opus |
| Planejar, arquitetura, desenho de API, decisão com trade-offs | Opus | high | plan mode (`/model opusplan`) |
| Refatoração grande, migração, tarefa longa e autônoma | Opus + Sonnet | high | plano no Opus, execução no Sonnet, uma parte por worktree |
| Desenho de pipeline de ML/dados, experimento, avaliação de LLM | Opus | high | plan mode |
| Segurança, auth, cripto, dados sensíveis, migração de banco | Opus | xhigh | na sessão + revisão num subagente Opus com contexto limpo |
| Revisar diff de rotina | Sonnet | medium | subagente com contexto limpo |
| Revisar diff de risco (infra, segurança, release) | Opus | high | subagente Opus com contexto limpo, separado de quem escreveu |
| Docs, README, ADR | Sonnet | medium | na sessão; ADR com decisão difícil, Opus |
