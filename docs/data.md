# Dados: bancos, CSV, Parquet e Excel

Tudo no terminal, sem app gráfico. Cada ferramenta tem um papel:

| Ferramenta | Para que | Comando |
| --- | --- | --- |
| [tabiew](https://github.com/shshemi/tabiew) | olhar um arquivo de tabela na hora, com SQL em cima | `tw arquivo.csv` |
| [harlequin](https://harlequin.sh) | IDE de SQL: editor, árvore de tabelas e resultados | `harlequin` |
| [DuckDB](https://duckdb.org) | SQL completo em arquivos e bancos; consultas salvas no projeto | `duckdb` |
| pgcli / litecli | consulta rápida num Postgres / SQLite, com completion | `pgcli $DATABASE_URL` |

Vêm do módulo de CLI (`devenv.cli.enable`). Escolha e comparação com as alternativas (dadbod, VisiData, sqlit, rainfrog…):
documento "Bancos e CSV no terminal" (2026-10-23).

## Fluxos

| Situação | Como |
| --- | --- |
| Chegou um CSV, Parquet ou planilha | `tw arquivo.xlsx`, ou `Enter` no yazi (tabelas abrem no tabiew; `O` mostra as outras opções) |
| Pergunta rápida sobre o arquivo | dentro do tabiew, `:` abre a linha de comando: `q SELECT …` roda SQL na tabela aberta |
| Juntar vários arquivos ou um arquivo grande | `duckdb -c "from 'dados/*.csv' select regiao, sum(valor) group by all"` |
| Guardar o resultado | `duckdb -c "copy (from 'dados/*.csv') to 'dados.parquet'"` |
| Análise que fica no projeto | consultas em `sql/*.sql`; no Neovim, `<leader>Dr` roda o arquivo (ou a seleção) e mostra o resultado num split |
| Explorar um banco | `harlequin` (DuckDB em memória), `harlequin banco.duckdb`, `harlequin -a sqlite app.db`, `harlequin -a postgres "$DATABASE_URL"` |
| Sem sair do Neovim | `<leader>Dh` harlequin, `<leader>Dt` tabiew, numa janela flutuante na raiz do projeto |
| Algo mais visual | `duckdb -ui` abre um notebook local no navegador (as consultas rodam na sua máquina; a interface é baixada de ui.duckdb.org) |

Caminhos relativos no SQL partem da raiz do projeto (a pasta com `.git`), tanto no terminal quanto no `<leader>Dr`.

## Conexões e senhas

Senha de banco nunca vai para arquivo do repo. Guarde a URL como segredo e use pela variável:

```bash
secrets edit                      # acrescente env/DATABASE_URL: postgres://usuario:senha@host/banco
```

```nix
devenv.secrets.env = [ "DATABASE_URL" ];   # no host; vale depois do `just switch`
```

Depois: `pgcli "$DATABASE_URL"` ou `harlequin -a postgres "$DATABASE_URL"`. Detalhes em [secrets.md](secrets.md).

## No Neovim

| Tecla | Ação |
| --- | --- |
| `<leader>Dr` | Rodar o `.sql` (ou a seleção) no DuckDB |
| `<leader>Db` | Escolher o banco do DuckDB para o buffer (vazio = em memória) |
| `<leader>Dh` / `<leader>Dt` | Harlequin / tabiew numa janela flutuante |

Para fixar um banco para a sessão inteira: `:let g:duckdb = 'dados/analise.duckdb'`.
