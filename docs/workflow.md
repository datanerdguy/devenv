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
4. Teste na sua máquina a partir da `dev`: `git switch dev && git pull && just apply && just sync`.
5. Quando a `dev` estiver boa: `gh pr create --base main --head dev --title "chore(release): ..."`. Merge por **merge commit** (não squash), para manter o histórico de cada mudança e as notas de release completas.

## Commits padronizados

Padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/), validado pelo [commitizen](https://commitizen-tools.github.io/commitizen/):

```text
<tipo>(<escopo opcional>): <descrição no imperativo>

feat(shell): adiciona abreviações do git
fix(terminal): corrige fonte do Ghostty
chore(deps): atualiza o grupo languages
docs: explica o fluxo de release
```

| Tipo | Quando | Efeito na versão |
| --- | --- | --- |
| `feat` | Algo novo (módulo, programa, atalho) | minor (0.**2**.0) |
| `fix` | Correção | patch (0.1.**1**) |
| `feat!` ou `BREAKING CHANGE:` no corpo | Muda algo de forma incompatível | major (enquanto estiver em 0.x, sobe o minor) |
| `docs`, `chore`, `ci`, `refactor`, `style`, `test`, `perf`, `build` | Resto | nenhum |

Escopos sugeridos: a área (`base`, `shell`, `terminal`, `temas`, `nvim`, `tmux`, `desktop`, `agents`, `keyboard`), ou `ci`, `deps`, `adr`, `docs`, `repo`.

**Hooks locais.** Rode `just setup` uma vez: ele liga os hooks de `.githooks/`.

- `pre-commit` roda `just lint`.
- `commit-msg` roda `cz check` na mensagem.

## Pipeline

### `ci.yml`: em todo PR e à mão

Não roda no push para `dev` e `main`: o que chega lá já passou pelo mesmo CI no PR, com a mesma árvore
(o PR `dev` → `main` testa exatamente o que vai para a `main`). Os dois jobs rodam num container
`archlinux:latest` com `--hostname ci`, que é o grupo `ci` do metapac (`base` e `repo`).

| Job | O que verifica |
| --- | --- |
| `lint` | `just lint`: shellcheck, actionlint, os grupos do metapac, os arquivos citados nos docs e o mapa do teclado (precisa do `keymap-drawer`, instalado com `uv tool`) |
| `apply` | Cria um usuário com sudo sem senha, roda o `./bootstrap.sh` (sem rbw logado), um segundo `metapac sync` (que não pode instalar nada) e o `tests/smoke.sh`: ferramentas no PATH, os links do chezmoi e as configs dos grupos instalados |

O CI testa só o Arch. O CachyOS usa os mesmos pacotes e o mesmo `paru`. No PR, o CI instala só `base` e `repo`. O resto fica de fora porque
pesa (vários pacotes do AUR são compilados).

Depois de mexer nessas listas, rode o CI completo à mão: `gh workflow run ci.yml --ref <branch> -f full=true`.
Ele usa o hostname `ci-full` (todos os grupos menos `debug` e `machines/`, conferido pelo `packages/check.py`) e
pode levar até duas horas. O `machines/cachyos` nunca roda no CI: é o sistema do instalador desta máquina.

### `pr.yml`: só em PR

Num workflow próprio porque só fazem sentido em PR.

| Job | O que verifica |
| --- | --- |
| `commits` | Título do PR e cada commit no padrão Conventional Commits |
| `source-branch` | Um PR para a `main` precisa vir da `dev` |

### `release.yml`: em todo push na `main`

O commitizen calcula a próxima versão pelos commits desde a última tag. Se houver `feat` ou `fix`, cria a tag `vX.Y.Z` e uma GitHub Release com as notas agrupadas por tipo. Só `docs`/`chore` não geram release. O changelog vive nas Releases do GitHub; não há commit de volta na `main`.

### Dependabot

Atualiza as versões das GitHub Actions toda semana, com PRs para a `dev`.
Todas as Actions ficam presas a um commit (SHA), com a versão no comentário (`# v4`): uma tag ou a `main`
de terceiros pode mudar sem aviso. O Dependabot atualiza o SHA e o comentário juntos.

## Proteção das branches (configurar no GitHub)

Em **Settings → Branches** (ou **Rules → Rulesets**), para `main` e `dev`:

- Exigir PR antes do merge.
- Exigir os checks `lint` e `apply`; na `main`, também `source-branch`; na `dev`, também `commits`.
- Bloquear force push e exclusão.
- Na `dev`: permitir só squash merge. Na `main`: permitir merge commit.

## Desfazer uma mudança

- Nos pacotes: o snap-pac tira um snapshot do btrfs a cada transação do pacman, então dá para voltar pelo snapper.
- Nas configs e nas listas: `git checkout vX.Y.Z && just apply && just sync`.
- No repo: `git revert` do commit (gera `revert: ...`) num PR para a `dev`.
