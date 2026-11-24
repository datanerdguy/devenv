# Modelos de projeto

Configs prontas para copiar num projeto novo, no mesmo estilo do devenv: 80 colunas, 2 espaços onde a linguagem não
tem regra própria e as regras de lint mais úteis ligadas. O Neovim lê cada uma sozinho, pelo LSP e pelo formatador
do `:w` ([neovim.md](../docs/neovim.md)). Num projeto, a config dele sempre vence a do editor.

Para usar, copie a pasta `common/` e a da linguagem para a raiz do projeto:

```fish
cp -r ~/Projects/devenv/templates/common/. ~/Projects/devenv/templates/python/. meu-projeto/
```

| Pasta | Arquivos | Para quê |
| --- | --- | --- |
| `common/` | `.editorconfig` | Indentação e 80 colunas em todo arquivo; o Neovim usa o limite na linha vertical |
| `python/` | `pyproject.toml` | ruff (lint e formato, 80 colunas, regras `E W F I B UP SIM`) e o grupo `dev` com ruff e ty. Troque o nome e a versão |
| `python-data/` | `pyproject.toml` | O mesmo do `python/`, com polars, duckdb e pyarrow, e o marimo para notebooks ([data.md](../docs/data.md)) |
| `go/` | `.golangci.yml` | golangci-lint v2, com bugs comuns, segurança e estilo; gofumpt e goimports formatam |
| `rust/` | `rustfmt.toml`, `lints.toml` | rustfmt em 80 colunas. O `lints.toml` vai colado no fim do `Cargo.toml`: clippy pedantic, sem `unsafe` |
| `typescript/` | `.prettierrc.json`, `tsconfig.json` | prettier em 80 colunas (o Neovim só roda o prettier em projeto com config dele) e TypeScript estrito |
| `elixir/` | `.formatter.exs` | mix format em 80 colunas. Num Phoenix, o `mix phx.new` já cria o arquivo: troque só o `line_length` |
| `lua/` | `.stylua.toml` | stylua, igual ao do devenv |
| `c/` | `.clang-format`, `.clang-tidy` | estilo do LLVM com 2 espaços, e os avisos do clang-tidy que o clangd mostra |

O `just lint` confere que cada ferramenta aceita o seu arquivo (`tests/check-templates.sh`).
