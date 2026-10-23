# 0006. Modelos de projeto: copier com um comando `new`, uv no Python e o mesmo `just ci` em todo lugar

Data: 2026-10-23 · Status: aceita

## Contexto

Projetos novos (ML, LLM, dados, web) precisam nascer com o mesmo padrão do devenv: ambiente reproduzível, lint,
tipos, testes, CI, hooks e instruções para os agentes. Copiar de um projeto antigo espalha diferenças, e um
modelo que não se atualiza envelhece. O ambiente tem de ser leve: abrir a pasta não pode demorar.

Opções avaliadas em detalhe: [documento da fase 7](https://claude.ai/artifact/GqoHk9qjUZMPj9jwuSGybh).

## Decisão

- **copier**, com os modelos neste repo (`copier.yml` e `templates/<linguagem>/`). Ele pergunta, gera e depois
  atualiza o projeto (`just template-update`) a partir das respostas guardadas.
- **Comando `new`** em volta do copier: preenche autor pelo git, cria o repositório, escreve o `flake.lock` com o
  nixpkgs do devenv (sem download novo), trava as dependências, instala os hooks e libera o direnv.
- **Ambiente**: `flake.nix` com um devShell só de ferramentas, carregado pelo direnv (nix-direnv, com cache).
- **Python**: o uv cuida do Python e das bibliotecas (o Nix não empacota bibliotecas Python); ruff, basedpyright e
  pytest. Oito tipos: lib, api, llm, data, ml, fastapi-htmx, django e streamlit.
- **Go** (cli, service, htmx) só com a biblioteca padrão e golangci-lint; **Rust** (bin, lib) com rustup
  (`rust-toolchain.toml`), clippy e nextest.
- **Web**: htmx com HTML do servidor (FastAPI + Jinja, Django, Go `html/template`), Streamlit para apps de dados;
  Phoenix no próximo PR. O htmx vem no projeto, sem CDN.
- **Mesmo `just ci`** na máquina, no CI do projeto (GitHub Actions sem Nix) e no CI do devenv, que gera
  cada tipo com o `new` e roda esse comando (`tests/templates.sh`).
- **Hooks com lefthook** (ruff no pre-commit, commitizen na mensagem).

## Alternativas consideradas

- **cookiecutter:** só gera, não atualiza o projeto depois.
- **`nix flake init -t`:** sem perguntas nem atualização; tudo teria de ser variantes fixas.
- **devenv.sh ou devbox:** mais uma camada sobre o Nix, e mais lenta para abrir que um devShell com nix-direnv.
- **Bibliotecas Python pelo Nix (uv2nix, poetry2nix):** reproduzível até o binário, mas lento de atualizar e
  quebra com rodas como a do PyTorch com CUDA. O `uv.lock` já fixa as versões.
- **pre-commit (framework):** baixa um ambiente por hook; o lefthook é um binário só e usa as ferramentas do projeto.

## Consequências

- Mudar o padrão de todos os projetos é editar `templates/` e rodar `just template-update` em cada um.
- O CI do devenv fica mais longo (um job por tipo), mas um modelo quebrado aparece no PR, não no projeto novo.
- O Python baixado pelo uv é o binário padrão do Linux: funciona no Fedora e no Ubuntu, não no NixOS (fora do alvo).
