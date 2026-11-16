# Instruções globais para agentes de código

Valem para o Claude Code. Fonte única no repo devenv (`agents/AGENTS.md`).
O `AGENTS.md` de cada projeto completa estas regras.

## Quem sou eu

- Lucas. Engenharia de ML/IA/LLM, MLOps, dados. Python, Go, Rust; aprendendo Elixir/Phoenix e htmx.
- Responda em português (pt-BR). Código, commits e identificadores em inglês, salvo se o projeto usar outro padrão.
- Ambiente: Fedora, fish, tmux, Neovim, Nix + home-manager (repo `~/devenv`).

## Como trabalhar

- Antes de mudar código, leia o que já existe e siga o estilo do projeto.
- Mudanças pequenas e verificáveis. Rode os testes e o lint do projeto antes de dizer que terminou.
- Commits no padrão Conventional Commits (`feat(escopo): ...`). Não faça push nem abra PR sem eu pedir.
- Nunca coloque segredos em arquivos ou commits. Segredos vêm do Bitwarden (`rbw get <nome>`) ou do sops (`secrets edit`).
- Python: `uv` (nunca `pip install` global). Go: módulos. Rust: cargo. Nix: `nix develop` / direnv.
- Ferramentas disponíveis: `rg`, `fd`, `jq`, `yq`, `duckdb`, `gh`, `just`.
- Antes de usar a API de uma biblioteca, consulte a documentação da versão do projeto (MCP `context7`, depois
  MCP `docs`). Não invente parâmetros nem funções.

## Agentes e modelos

- Só o que o Claude Code oferece: modelos `haiku`, `sonnet`, `opus` e `opusplan`, effort `low` a `max` e
  subagentes (`Explore`, `Plan`, `general-purpose`). A skill `route` escolhe modelo e effort por tarefa.
- Assinatura Claude Pro: Haiku gasta pouco, Sonnet é o padrão, Opus gasta bem mais. **Fable não entra no Pro:**
  não use, nem em subagente, salvo pedido meu.
- Escolha o menor modelo e effort que resolvem, e suba se o resultado não servir. Antes de trocar de modelo,
  tente subir o effort. `max` só quando `xhigh` falhou numa tarefa crítica. Planejar, arquitetura e segurança
  pedem Opus; sugira `/model opus` ou `opusplan` antes de começar.
- Subagente só para busca ampla, partes independentes em paralelo ou revisão com olhar limpo. No máximo 3.
  Sempre com o modelo explícito (sem isso herda o da sessão) e um pedido autocontido. Subagente não cria outro.
- Trabalho longo em paralelo: uma tarefa por worktree com `workmux add <nome> -a claude -p "<pedido>"`.
