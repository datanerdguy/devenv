# Fluxo de trabalho

Duas branches: a `dev`, onde você muda e testa, e a `main`, o que está bom. Sem PR.

1. `git switch dev`, mude, faça o commit e o push. O CI (lint e smoke numa máquina Arch nova) roda a cada push.
2. Teste na sua máquina: `just apply && just sync`.
3. Quando a `dev` estiver boa: `just promote`. A `main` avança até a `dev` do GitHub. Se a `main` tiver algo que a
   `dev` não tem, ele recusa em vez de apagar.

Mudança grande ou arriscada pode ir numa branch própria (`feat/...`) e entrar na `dev` quando estiver pronta.

## Commits

No padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/), em português:
`feat(shell): abreviações do git`, `fix(nvim): ...`, `docs: ...`. O hook `commit-msg` confere cada mensagem
(commitizen); `just commit` monta a mensagem perguntando. `just setup` liga os hooks: o `pre-commit` roda o
`just lint` antes de cada commit.

| Tipo | Quando |
| --- | --- |
| `feat` | Algo novo |
| `fix` | Conserto |
| `refactor` | Muda a estrutura, não o comportamento |
| `docs`, `test`, `ci`, `chore` | Só docs, testes, CI ou manutenção |

## CI

O `ci.yml` roda o `just lint` e o `tests/smoke.sh` num container Arch, com os grupos `base` e `repo`. Depois de
mexer nas listas de pacotes, rode o CI completo à mão, com todos os grupos (o `ci-full` de `packages/config.toml`):

```fish
gh workflow run ci.yml --ref dev -f full=true
```
