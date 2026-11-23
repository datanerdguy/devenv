# 0002. Branch dev, CI/CD e commits padronizados

Data: 2026-10-23 · Status: aceita

## Contexto

Uma mudança nos dotfiles pode quebrar o ambiente de trabalho inteiro. É preciso testar antes de aplicar na máquina principal e saber exatamente o que mudou em cada versão.

## Decisão

- Duas branches de longa duração: `dev` (integração e teste) e `main` (estável). Tudo chega na `main` por PR vindo da `dev`.
- CI no GitHub Actions em todo PR: lint, build de todos os hosts e instalação do zero em containers Fedora e Ubuntu com testes de fumaça.
- **Conventional Commits** validados pelo **commitizen**, no hook local e no CI.
- Versão semântica e notas de release geradas pelo commitizen a cada push na `main`, publicadas como GitHub Release.
- `flake.lock` atualizado toda semana por PR automático para a `dev`.

## Alternativas consideradas

- **commitlint + semantic-release:** padrão no mundo Node, mas traz Node e npm para um repo que não usa. O commitizen faz validação, commit guiado, versão e notas num único binário, disponível no nixpkgs.
- **cocogitto / git-cliff:** ótimos e rápidos (Rust); ficam como alternativa se o commitizen pesar.
- **release-please:** abre PRs de release e mantém CHANGELOG.md, mas exige commits de volta na `main`, o que complica o fluxo com a `dev`.

## Consequências

- Mensagens fora do padrão são barradas no commit e no PR.
- Merge para a `dev` é por squash (o título do PR vira o commit); da `dev` para a `main` é merge commit, para preservar o histórico usado nas notas.
- As regras de proteção das branches precisam ser ligadas uma vez no GitHub (ver `docs/workflow.md`).

## Atualização (2026-11-16)

O PR automático e semanal do `flake.lock` saiu. Ele falhava porque o GitHub Actions não pode abrir PR neste
repo, e um PR aberto pelo `GITHUB_TOKEN` não dispararia o CI. O `flake.lock` passa a ser atualizado à mão com
`just update`, num PR comum (`docs/workflow.md`).
