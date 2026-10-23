# Instruções globais para agentes de código

Valem para Claude Code, Codex, Gemini CLI e opencode. Este arquivo é a fonte única:
o devenv o liga em `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/AGENTS.md`
e `~/.config/opencode/AGENTS.md`. O `AGENTS.md` de cada projeto completa estas regras.

## Quem sou eu

- Lucas. Engenharia de ML/IA/LLM, MLOps, dados. Python, Go, Rust; aprendendo Elixir/Phoenix e htmx.
- Responda em português (pt-BR). Código, commits e identificadores em inglês, salvo se o projeto usar outro padrão.
- Ambiente: Fedora, fish, tmux, Neovim, Nix + home-manager (repo `~/devenv`).

## Como trabalhar

- Antes de mudar código, leia o que já existe e siga o estilo do projeto.
- Mudanças pequenas e verificáveis. Rode os testes e o lint do projeto antes de dizer que terminou.
- Commits no padrão Conventional Commits (`feat(escopo): ...`). Não faça push nem abra PR sem eu pedir.
- Nunca coloque segredos em arquivos ou commits. Segredos vêm do Bitwarden (`rbw get <nome>`).
- Python: `uv` (nunca `pip install` global). Go: módulos. Rust: cargo. Nix: `nix develop` / direnv.
- Ferramentas disponíveis: `rg`, `fd`, `jq`, `yq`, `duckdb`, `gh`, `just`.

## Documentação de bibliotecas

- Antes de usar a API de uma biblioteca, consulte a documentação da versão do projeto:
  MCP `context7` primeiro; se não tiver a biblioteca, MCP `docs` (índice local).
- Não invente parâmetros nem funções: na dúvida, consulte.

## Roteamento entre agentes

Use a tabela para decidir quem faz o quê. Pode chamar outro agente em modo não interativo
(skill `second-opinion` ou `route`), sempre com um pedido curto e autocontido.

| Tarefa | Agente | Modelo |
| --- | --- | --- |
| Planejar, arquitetura, refatoração grande | Claude Code | Opus (plan mode) |
| Implementar e testar | Claude Code | Sonnet |
| Buscar no código, resumir logs | subagente Explore do Claude | Haiku |
| Revisão independente de um diff | Codex (`codex exec`) | padrão |
| Ler muito contexto (repo inteiro, PDFs longos) | Gemini CLI (`gemini -p`) | Gemini Pro |
| Modelos abertos ou locais | opencode (`opencode run`) | Ollama ou outro |

- A cota do Claude Pro é limitada: mande busca e leitura pesada para o subagente Explore ou o Gemini.
- Trabalho em paralelo: uma tarefa por worktree com `workmux add <nome> -p "<pedido>"`.
