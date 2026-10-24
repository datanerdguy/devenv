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
- Nunca coloque segredos em arquivos ou commits. Segredos vêm do Bitwarden (`rbw get <nome>`) ou do sops (`secrets edit`, docs/secrets.md).
- Python: `uv` (nunca `pip install` global). Go: módulos. Rust: cargo. Nix: `nix develop` / direnv.
- Ferramentas disponíveis: `rg`, `fd`, `jq`, `yq`, `duckdb`, `gh`, `just`.

## Documentação de bibliotecas

- Antes de usar a API de uma biblioteca, consulte a documentação da versão do projeto:
  MCP `context7` primeiro; se não tiver a biblioteca, MCP `docs` (índice local).
- Não invente parâmetros nem funções: na dúvida, consulte.

## Roteamento entre agentes

Use a tabela para decidir quem faz o quê. Pode chamar outro agente em modo não interativo
(skill `second-opinion` ou `route`), sempre com um pedido curto e autocontido.

| Tarefa | Agente |
| --- | --- |
| Tudo que muda código no dia a dia | Claude Code (modelo e effort na seção abaixo) |
| Revisão independente de um diff | Codex (`codex exec`) |
| Ler muito contexto (repo inteiro, PDFs longos) | Gemini CLI (`gemini -p`) |
| Modelos abertos ou locais | opencode (`opencode run`) |

- Trabalho em paralelo e longo: uma tarefa por worktree com `workmux add <nome> -p "<pedido>"`, no máximo 3.

## Modelos do Claude (assinatura Pro)

- Entram na cota do Pro: **Haiku 5.5** (gasta pouco), **Sonnet 5.5** (moderado) e **Opus 5.5** (gasta bem mais).
- **Fable 5.1 não entra no Pro**: é cobrado à parte, em créditos. Não use, nem em subagente, salvo pedido meu.
- Effort (`/effort`, `--effort`, `effort:` no frontmatter): `low`, `medium` (padrão), `high`, `xhigh`, `max`.
  Effort maior gasta mais tokens e tempo. Antes de trocar para um modelo maior, tente subir um nível de effort.
- `max` só quando `xhigh` falhou e a tarefa é crítica: ganha pouco, custa muito, e às vezes rende menos que `xhigh`.

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
| Planejar, arquitetura, desenho de API, decisão com trade-offs | Opus | high | plan mode (`/model opusplan`: Opus planeja, Sonnet executa) |
| Refatoração grande, migração, tarefa longa e autônoma | Opus + Sonnet | high | plano no Opus, execução no Sonnet, uma parte por worktree |
| Desenho de pipeline de ML/dados, experimento, avaliação de LLM | Opus | high | plan mode |
| Segurança, auth, cripto, dados sensíveis, migração de banco | Opus | xhigh | na sessão + `/second-opinion` |
| Revisar diff de rotina | Sonnet | medium | subagente com contexto limpo |
| Revisar diff de risco (infra, segurança, release) | Opus | high | subagente + `/second-opinion` (Codex) |
| Docs, README, ADR | Sonnet | medium | na sessão; ADR com decisão difícil, Opus |

- A sessão abre em Sonnet. Se a tarefa pede Opus pela tabela, sugira `/model opus` (ou `opusplan`) antes de começar;
  sessão em Opus com tarefa de rotina, sugira `/model sonnet`.
- Na dúvida entre dois níveis, escolha o menor e suba se o resultado não servir.

### Subagentes

- **Crie** um subagente quando: a busca é ampla e encheria o contexto; há tarefas independentes que podem rodar
  em paralelo (no máximo 3); ou você quer uma revisão com olhar limpo.
- **Não crie** quando: a tarefa é pequena (poucos arquivos já conhecidos); os passos dependem um do outro;
  ou o trabalho precisa do contexto da conversa (o subagente começa do zero e repete a leitura).
- **Sempre diga o modelo** do subagente (parâmetro `model` ou `model:` no frontmatter). Sem isso ele herda o da
  sessão, e uma busca em Opus gasta cota à toa. Haiku lê e busca; Sonnet edita código; Opus só planeja ou revisa algo crítico.
- O pedido é autocontido: objetivo, arquivos ou pastas, critério de pronto e formato curto da resposta.
- Subagente não cria outro subagente. Agent teams só com `cteam` e quando eu pedir.
