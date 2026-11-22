# Instruções globais para agentes de código

Valem para o Claude Code em todo projeto. A fonte fica no repo devenv (`agents/AGENTS.md`), e o chezmoi liga
`~/.claude/CLAUDE.md` a este arquivo. O `AGENTS.md` de cada projeto completa estas regras.

## Quem sou eu

- Lucas. Engenharia de ML/IA/LLM, MLOps, dados. Python, Go, Rust; aprendendo Elixir/Phoenix e htmx.
- Responda em português (pt-BR). Código, commits e identificadores em inglês, salvo se o projeto usar outro padrão.
- Ambiente: CachyOS, fish, Neovim, chezmoi + metapac (repo `~/devenv`).

## Como trabalhar

- Antes de mudar código, leia o que já existe e siga o estilo do projeto.
- Mudanças pequenas e verificáveis. Rode os testes e o lint do projeto antes de dizer que terminou.
- Commits no padrão Conventional Commits (`feat(escopo): ...`). Não faça push nem abra PR sem eu pedir.
- Nunca coloque segredos em arquivos ou commits. Segredos vêm do Bitwarden (`rbw get <nome>`) ou do chezmoi com age.
- Python: `uv` (nunca `pip install` global). Go: módulos. Rust: cargo. A versão de cada linguagem é a do projeto
  (rustup, `GOTOOLCHAIN`, uv, mise).
- Ferramentas disponíveis: `rg`, `fd`, `jq`, `gh`, `just`.
- Antes de usar a API de uma biblioteca, consulte a documentação da versão do projeto pelo MCP `context7`.
  Não invente parâmetros nem funções.

## Modelos

- Assinatura Claude Pro, sem chave de API. Sonnet é o padrão da sessão; Opus gasta bem mais cota e fica para
  planejar, arquitetura, bugs difíceis e segurança (sugira `/model opus` antes de começar).
- **Não use Fable**, nem em subagente, salvo pedido meu.
- Antes de trocar de modelo, tente subir o effort.
- Os modelos dos papéis do pstack ficam em `~/.claude/pstack-models.md`, importado abaixo.

@~/.claude/pstack-models.md
