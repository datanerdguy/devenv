# Dados

Ferramentas para olhar arquivos, escrever SQL, falar com bancos e rodar os serviços de cada projeto. As decisões
ficam no [ADR 0015](adr/0015-data.md). A máquina tem uma GPU de 2 GB e 7,6 GB de RAM: treino e LLM grande ficam na
nuvem ou num servidor.

## No terminal

| Comando | Para quê |
| --- | --- |
| `duckdb` | SQL direto em CSV, Parquet e JSON, sem servidor (`select * from 'dados.parquet'`) |
| `vd arquivo` | Abre CSV, Parquet, JSON ou Excel como planilha (visidata): `q` sai, `[` e `]` ordenam, `F` conta valores |
| `harlequin` | Editor de SQL no terminal, com as tabelas ao lado: `harlequin dados.duckdb`, ou `harlequin -a postgres <url>` |
| `psql` | Cliente do Postgres (só o cliente; o banco roda em container) |

No Neovim, CSV e TSV abrem em colunas alinhadas (csvview), e `Tab` / `Shift-Tab` andam entre os campos.

## Containers (Podman)

O Podman roda sem root e sem serviço ligado o tempo todo. O comando `docker` chama o `podman` (pacote
`podman-docker`), e o `podman compose` lê o `compose.yaml` do projeto. Bancos (Postgres, Redis...) rodam assim, por
projeto, e nunca instalados na máquina:

```yaml
# compose.yaml do projeto
services:
  db:
    image: docker.io/library/postgres:18
    environment:
      POSTGRES_PASSWORD: dev
    ports: ["5432:5432"]
```

`podman compose up -d` sobe, `podman compose down` para. Programas feitos para o Docker (compose, testcontainers,
devcontainers) falam com o Podman pelo socket dele: o chezmoi liga o `podman.socket` do systemd do usuário (só
acorda quando alguém usa), e o fish aponta o `DOCKER_HOST` para ele.

## Python

Nada global: cada projeto tem as bibliotecas dele, pelo `uv`. O modelo `templates/python-data/`
([templates/README.md](../templates/README.md)) traz polars, duckdb e pyarrow, com marimo, ruff e ty para
desenvolver.

| Notebook | Quando |
| --- | --- |
| marimo (`uv run marimo edit nb.py`) | Padrão dos projetos novos: o notebook é um `.py`, com diff limpo no git, e roda como script |
| Jupyter (`uv run --with jupyterlab jupyter lab`) | Projeto ou time que já usa `.ipynb` |

## Nuvem e MLOps

Ainda nada na máquina. Quando um projeto precisar (AWS, Kubernetes, Terraform...), a ferramenta entra nele, pelo
`mise use` (a versão fica no `mise.toml` do projeto).
