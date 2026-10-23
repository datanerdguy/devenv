# Fluxo de trabalho e CI/CD

Toda mudança passa por `dev` antes de chegar na `main`. A `main` é sempre o que está instalado nas máquinas; a `dev` é onde as mudanças são testadas juntas.

```text
feat/minha-mudanca ──PR (squash)──▶ dev ──PR (merge)──▶ main ──▶ tag vX.Y.Z + GitHub Release
        │                            │                     │
        └─ CI completo               └─ CI completo        └─ CI completo + release
```

## Branches

| Branch | Para quê | Como recebe mudanças |
| --- | --- | --- |
| `main` | Versão estável, aplicada nas máquinas | Só por PR vindo da `dev`, com CI verde |
| `dev` | Integração e teste | Por PR de branches de trabalho, com CI verde |
| `feat/*`, `fix/*`, `chore/*`, `docs/*` | Uma mudança por branch | Commits livres, no padrão abaixo |

Passo a passo de uma mudança:

1. `git switch dev && git pull && git switch -c feat/tmux`
2. Commits com `just commit` (guiado) ou `git commit` (o hook valida a mensagem).
3. `gh pr create --base dev`; o CI roda. Merge por **squash**, então o título do PR vira o commit na `dev`.
4. Teste na sua máquina a partir da `dev`: `git switch dev && git pull && just switch`.
5. Quando a `dev` estiver boa: `gh pr create --base main --head dev --title "chore(release): ..."`. Merge por **merge commit** (não squash), para manter o histórico de cada mudança e as notas de release completas.

## Commits padronizados

Padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/), validado pelo [commitizen](https://commitizen-tools.github.io/commitizen/):

```text
<tipo>(<escopo opcional>): <descrição no imperativo>

feat(shell): adiciona abreviações do git
fix(terminal): corrige fonte do Ghostty
chore(deps): atualiza flake.lock
docs: explica o fluxo de release
```

| Tipo | Quando | Efeito na versão |
| --- | --- | --- |
| `feat` | Algo novo (módulo, programa, atalho) | minor (0.**2**.0) |
| `fix` | Correção | patch (0.1.**1**) |
| `feat!` ou `BREAKING CHANGE:` no corpo | Muda algo de forma incompatível | major (enquanto estiver em 0.x, sobe o minor) |
| `docs`, `chore`, `ci`, `refactor`, `style`, `test`, `perf`, `build` | Resto | nenhum |

Escopos sugeridos: o nome do módulo (`cli`, `shell`, `git`, `terminal`, `nvim`, `tmux`, `desktop`, `theme`, `agents`), ou `ci`, `deps`, `system`.

**Hooks locais.** Ao entrar no repo com direnv (ou rodar `nix develop`), o devShell liga os hooks de `.githooks/`:

- `pre-commit` roda `just lint` (formatação, statix, shellcheck, actionlint).
- `commit-msg` roda `cz check` na mensagem.

## Pipeline

### `ci.yml`: em todo PR e todo push para `dev` e `main`

| Job | O que verifica |
| --- | --- |
| `lint` | `nix fmt` sem mudanças, statix (Nix), shellcheck (scripts), actionlint (workflows) |
| `commits` | Só em PR: título do PR e cada commit no padrão Conventional Commits |
| `build` | `nix flake check` e build de todos os hosts em `homeConfigurations` |
| `install` | Instalação do zero em containers limpos **Fedora** e **Ubuntu**: instala Nix, aplica o host `ci` e roda `tests/smoke.sh` |

`tests/smoke.sh` confere que os programas existem, que fish e starship iniciam, e que as configs de git, Ghostty, starship e direnv foram geradas. Para rodar localmente: `just test-container fedora:latest`.

### `release.yml`: em todo push na `main`

O commitizen calcula a próxima versão pelos commits desde a última tag. Se houver `feat` ou `fix`, cria a tag `vX.Y.Z` e uma GitHub Release com as notas agrupadas por tipo. Só `docs`/`chore` não geram release. O changelog vive nas Releases do GitHub; não há commit de volta na `main`.

### `update-flake-lock.yml`: toda segunda-feira, 09:00 UTC

Abre um PR `chore(deps): atualiza flake.lock` contra a `dev`. O CI do PR constrói e testa tudo com as versões novas. Use `just diff` localmente para ver pacote a pacote o que mudou.

### Dependabot

Atualiza as versões das GitHub Actions toda semana, com PRs para a `dev`.

## Proteção das branches (configurar no GitHub)

Em **Settings → Branches** (ou **Rules → Rulesets**), para `main` e `dev`:

- Exigir PR antes do merge.
- Exigir os checks `lint`, `build`, `install (fedora:latest)` e `install (ubuntu:24.04)`; na `dev`, também `commits`.
- Bloquear force push e exclusão.
- Na `dev`: permitir só squash merge. Na `main`: permitir merge commit.

## Desfazer uma mudança

- Na máquina: `just generations` e ativar uma geração anterior, ou `git checkout vX.Y.Z && just switch`.
- No repo: `git revert` do commit (gera `revert: ...`) num PR para a `dev`.
