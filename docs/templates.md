# Modelos de projeto

O comando `new` cria um projeto pronto para trabalhar: ambiente no `flake.nix` (o direnv carrega ao entrar na
pasta), atalhos no `justfile`, lint, tipos e testes, CI no GitHub Actions, hooks do git e instruções para os
agentes (`AGENTS.md`).

Módulo: [`modules/templates`](../modules/templates/default.nix) (`devenv.templates.enable`).
Modelos: [`templates/`](../templates/) e [`copier.yml`](../copier.yml). Decisão: [ADR 0006](adr/0006-modelos-de-projeto.md).

## Criar

```sh
new python meu-site fastapi-htmx    # linguagem, pasta e tipo
new python minha-lib                # pergunta o tipo e o resto
new python dados data --defaults    # sem perguntas, tudo no padrão
new python api api -d postgres=true # responde uma pergunta direto
cd meu-site && just
```

O `new` pergunta nome, descrição, licença e o que fizer sentido para o tipo (Postgres, Docker, GPU), já preenche
autor e e-mail com os do git, e no fim:

1. cria o repositório git com o primeiro commit;
2. escreve o `flake.lock` com o mesmo nixpkgs do devenv, então nada novo é baixado;
3. trava as dependências (`uv.lock`) e instala os hooks (lefthook);
4. roda `direnv allow`.

## Python

O uv cuida do Python e das bibliotecas (`pyproject.toml` e `uv.lock`); o Nix só traz as ferramentas (uv, just,
lefthook, commitizen e, com Postgres, o banco). Em todo tipo: ruff (formatação e lint), basedpyright (tipos),
pytest, código em `src/<pacote>/`.

| Tipo | Para quê | Stack | Perguntas extras |
| --- | --- | --- | --- |
| `lib` | biblioteca, pacote publicável | só Python | |
| `api` | API HTTP | FastAPI, pydantic-settings | Postgres, Docker |
| `llm` | app ou agente de LLM | pydantic-ai (modelo em `LLM_MODEL`, padrão Ollama local); testes com `TestModel`, sem rede | |
| `data` | análise e pipelines de dados | polars, duckdb, notebooks do marimo | |
| `ml` | machine learning | PyTorch, notebooks do marimo | GPU |
| `fastapi-htmx` | site com HTML do servidor | FastAPI, Jinja, htmx | Postgres, Docker |
| `django` | site completo (admin, banco, login) | Django, django-htmx, htmx | Postgres, Docker |
| `streamlit` | app de dados rápido | Streamlit, polars | Docker |

- **htmx** vem junto no projeto (`static/htmx.min.js`), sem CDN. As rotas que o htmx chama devolvem só o pedaço de
  HTML que muda (templates que começam com `_`).
- **GPU** (`ml`): o PyTorch vem do índice oficial, só CPU (bem menor) ou com CUDA 12.8. Trocar depois é mudar a
  url em `[[tool.uv.index]]` no `pyproject.toml` e rodar `just sync`.
- **Postgres**: `just db` sobe o banco (process-compose), com os dados em `.devenv/pg`, fora do git. O `.envrc`
  define o `DATABASE_URL`. No `django`, sem Postgres, o banco é SQLite.
- **Docker**: `just docker` gera a imagem, no padrão do uv (dependências numa camada própria, usuário sem root).
  O CI do projeto também gera a imagem.
- **Segredos**: no `.envrc.local` (fora do git), por exemplo `export OPENAI_API_KEY="$(rbw get openai)"`.

## No projeto

| Comando | O que faz |
| --- | --- |
| `just dev` | roda o projeto (servidor, app, notebooks ou o agente, conforme o tipo) |
| `just test` | testes |
| `just fmt` | formata e corrige |
| `just ci` | tudo que o CI roda; o CI do GitHub chama o mesmo comando |
| `just template-update` | traz as mudanças do modelo do devenv (veja abaixo) |
| `cz commit` | commit guiado no padrão Conventional Commits (o hook confere a mensagem) |

O GitHub Actions do projeto não usa o Nix: instala o uv e o just e roda `just ci`, que é mais rápido.
O Dependabot abre um PR por semana com as dependências novas (uv, actions e a imagem Docker).

## Atualizar a partir do modelo

O projeto guarda as respostas em `.copier-answers.yml`. Quando o modelo muda no devenv, `just template-update`
aplica a diferença no projeto (pelo copier, com conflitos marcados como num merge do git). Faça com a árvore
limpa, para revisar com `git diff`.

## Como funciona

- [`copier.yml`](../copier.yml) tem as perguntas. A resposta de `lang` escolhe a pasta do modelo
  (`templates/<linguagem>/`).
- Arquivos `.jinja` são preenchidos com as respostas; os outros são copiados como estão (por isso os templates HTML
  do Jinja e do Django não levam `.jinja`).
- Nomes com condição entram só quando ela vale: `{% if docker %}Dockerfile{% endif %}.jinja`. Cada tipo do Python
  tem as suas pastas `src` e `tests`, com nomes como `{% if kind == 'api' %}src{% endif %}`.
- O que é igual em toda linguagem fica em [`templates/common/`](../templates/common/) e entra por link simbólico:
  `.envrc`, `.editorconfig`, licença, `.cz.toml` e o htmx.

## Mudar ou adicionar um modelo

1. Edite os arquivos em `templates/` (e as perguntas no `copier.yml`, se precisar).
2. Teste: `tests/templates.sh python:api` gera o projeto com o `new` e roda o `just ci` dele.
   Sem argumentos testa todos; com `DEVENV_TEST_DOCKER=1` também gera as imagens Docker.
3. O CI roda o mesmo teste para cada tipo (job `template`).

Para um tipo novo do Python: some a opção em `python_kind`, crie as pastas `src` e `tests` do tipo e ponha as
dependências no `pyproject.toml.jinja`. Para uma linguagem nova: some em `lang` e crie `templates/<linguagem>/`.

## Próximos

Go (cli, service, htmx), Rust (bin, lib) e Phoenix entram nos próximos PRs.
