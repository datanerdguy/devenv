# 0003. Agentes de código: configuração, roteamento e paralelismo

Data: 2026-10-23 · Status: aceita

## Contexto

O trabalho do dia a dia passa por agentes de código no terminal. O Claude Code é o principal, pela assinatura Pro
(sem chave de API), e os outros complementam: revisão independente, contexto longo, modelos abertos. Cada agente tem
seu formato de config, de instruções e de skills, e todos mudam rápido. É preciso que a configuração seja
versionada sem brigar com os agentes, que também escrevem nesses arquivos, e que o uso da cota fique visível.

## Decisão

- **Quatro agentes** (Claude Code, Codex, Gemini CLI, opencode) instalados pelo **llm-agents.nix** da numtide, com o cache binário deles. Sem `follows` no nixpkgs, para acertar o cache.
- **Instruções**: um `AGENTS.md` só, ligado nos quatro (o Claude importa pelo `CLAUDE.md`). Skills em `~/.agents/skills` e `~/.claude/skills`.
- **Configs**: o Nix gera um fragmento com as chaves gerenciadas e o `merge-config.py` mescla no arquivo do agente a cada switch, em vez de links somente leitura.
- **Roteamento** por tabela no `AGENTS.md` + skills (`route`, `second-opinion`) que chamam os outros CLIs em modo não interativo.
- **Paralelismo** com **workmux** (worktree + janela do tmux por tarefa, status dos agentes na janela).
- **Agent teams** do Claude disponíveis, mas desligadas (`cteam` liga numa sessão).
- **Métricas**: statusline do Claude (modelo, contexto, cota, custo), cota na barra do tmux, **tokscale** para o histórico. OpenTelemetry fica opcional.
- **Docs de bibliotecas**: MCP **context7** + **docs-mcp-server** local.
- **Modelos locais**: módulo do Ollama, desligado por padrão e sem subir no login.
- **Sandbox** nativo do Claude Code (bubblewrap) e do Codex.

## Alternativas consideradas

- **Proxy de roteamento (LiteLLM, claude-code-router):** escolhe modelo por requisição, mas exige chaves de API e não funciona com a assinatura Pro.
- **Pacotes do nixpkgs:** atrasam dias ou semanas em relação aos lançamentos; o llm-agents.nix atualiza todo dia.
- **Configs como links do home-manager:** os agentes falham ou perdem login ao tentar escrever num arquivo somente leitura.
- **Outros orquestradores (claude-squad, uzi, Conductor):** o workmux é o que integra direto com o tmux, tem painel e suporta os quatro agentes.
- **ccusage / ccflare:** o ccusage cobre só o Claude; o tokscale lê os quatro agentes. O ccflare é um proxy.
- **Ollama sempre ligado:** ocupa memória e GPU o tempo todo; fica sob demanda.

## Consequências

- Uma chave gerenciada mudada à mão volta ao valor do repo no próximo switch.
- Atualizar os agentes é `just agents-update`; a atualização semanal do `flake.lock` também atualiza.
- Cada agente pede login na primeira vez; os segredos ficam no Bitwarden (`rbw`).
- Ubuntu 24.04+ precisa do perfil do AppArmor para o bubblewrap (feito pelo `system/ubuntu.sh`).
