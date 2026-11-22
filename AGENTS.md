# devenv: instruções para agentes de código

Este repo é o ambiente de desenvolvimento do Lucas no CachyOS (Arch): configs pelo chezmoi (`home/`) e pacotes
pelo metapac (`packages/`). Comece pelo [README](README.md); as decisões e o porquê ficam em
[`docs/adr/`](docs/adr/), e os termos no [GLOSSARY](GLOSSARY.md).

## Regras do projeto

- **Idioma:** docs, comentários, mensagens de commit e títulos de PR em português (pt-BR), frases curtas e simples.
- **Desempenho importa:** tudo leve. Antes de acrescentar uma ferramenta, veja se uma que já existe resolve.
- **Pesquisar antes de criar:** área nova (ferramenta, módulo, fluxo) começa com opções comparadas e uma
  recomendação para o Lucas decidir. Não implemente uma área nova sem essa decisão.
- **Pacote novo vai no grupo certo do metapac** (`packages/groups/`): o comentário no topo de cada arquivo diz para
  que serve o grupo. Grupo novo entra em uma máquina e no `ci-completo` de `packages/config.toml`.
  Um pacote aparece uma vez só entre todos os grupos. O que é só desta máquina fica em `maquinas/<máquina>`.
- **Configs em `home/` são links para o repo** (editar já vale). O chezmoi cria os links no `just apply`.
- **Versões por projeto:** rustup, Go, uv e mise (Node, Erlang/Elixir, Java, Lua) escolhem a versão dentro de cada
  projeto. A ferramenta do projeto vence a da lista de pacotes.
- **As áreas shell, terminal e temas, tmux e Neovim são do Lucas.** O agente só ajuda quando ele pedir.
- **Segredos:** nunca no repo nem em texto plano. Cifrados com chezmoi + age; tokens pelo `rbw` na hora.
  O disco não é cifrado, então arquivo com segredo fica com permissão 0600.
- **Agentes:** assinatura Claude Pro, sem chave de API. Nada que dependa de API key paga.
- **Documente tudo:** mudou algo que o usuário vê, atualize o README e o doc da área.

## Regras e o que as garante

Cada regra que já foi quebrada mais de uma vez tem uma checagem. As sem checagem pedem julgamento.

| Regra | Quem garante |
| --- | --- |
| Um pacote aparece em um grupo só; todo grupo começa com um comentário, está em uma máquina e no `ci-completo` | `packages/checar.py` (`just lint`) |
| Nenhum programa escreve no repo pelos links do chezmoi (hooks de pacote, modelos do Noctalia) | `tests/smoke.sh` no CI. A config precisa já ter a linha que o programa acrescenta, ou o programa ganha um arquivo comum fora do repo (`create_`, como o `~/.gitconfig`) |
| As paletas batem com o gerador | `temas/gerar.py --check` (`just lint` e smoke) |
| O mapa do teclado bate com o `.vil` | `keyboard/render.py --check` (`just lint`) |
| Scripts e workflows sem erro | `shellcheck` e `actionlint` (`just lint`) |
| Config do niri e do Noctalia válida | `niri validate` (`just lint`) e smoke |
| Config do tmux sem erro | tmux num socket próprio (`just lint` e smoke) |
| Mensagem de commit e título do PR no padrão | `.githooks/commit-msg` e `pr.yml` |
| Uma checagem nova falha no erro que ela previne | julgamento: rode contra o erro antes de confiar |
| Docs dizem o que o código faz | julgamento: confira contra o arquivo antes de escrever |

## Fluxo de git

- Branch de trabalho (`feat/*`, `fix/*`, `chore/*`, `docs/*`) saindo da `dev` → PR para a `dev` (squash) →
  PR `dev` → `main` (merge commit, título `chore(release): ...`). Detalhes em [docs/workflow.md](docs/workflow.md).
- Conventional Commits, validados pelo commitizen. O título do PR também precisa passar (`cz check --message "<título>"`).
- Rode `just setup` uma vez: os hooks de `.githooks/` rodam o lint e validam a mensagem.
- Use o modelo de PR (`.github/pull_request_template.md`): O que muda, Como testei, Notas.
- O Lucas faz o merge. Não mexa nas regras do repositório.

## Comandos

`just --list` mostra todos (a tabela fica no [README](README.md)). Antes de dizer que terminou, rode `just lint`.

## Onde fica cada coisa

| Área | Código | Doc |
| --- | --- | --- |
| Configs (chezmoi) | `home/`, `.chezmoiroot` | README |
| Pacotes (metapac) | `packages/config.toml`, `packages/groups/` | [ADR 0010](docs/adr/0010-devenv-sem-nix-chezmoi-metapac.md) |
| Máquina nova | `bootstrap.sh`, `tests/smoke.sh` | README |
| Shell (fish) | `home/dot_config/fish/` | [docs/shell.md](docs/shell.md) |
| tmux | `home/dot_config/tmux/`, `home/dot_config/sesh/`, `home/dot_config/workmux/` | [docs/tmux.md](docs/tmux.md), [ADR 0014](docs/adr/0014-tmux.md) |
| Desktop | `home/dot_config/niri/`, `home/dot_config/noctalia/` | [docs/desktop.md](docs/desktop.md), [ADR 0012](docs/adr/0012-desktop-e-teclado.md) |
| Temas | `temas/gerar.py`, `home/dot_config/noctalia/palettes/` e `templates/` | [docs/temas.md](docs/temas.md), [ADR 0013](docs/adr/0013-temas-pelo-noctalia.md) |
| Teclado | `keyboard/` (`corne/corne.vil` é a fonte) | [keyboard/README.md](keyboard/README.md), [docs/desktop.md](docs/desktop.md) |
| Agentes e git | `agents/`, `home/dot_claude/`, `home/dot_config/git/` | [docs/agents.md](docs/agents.md), [ADR 0011](docs/adr/0011-agentes-e-git.md) |
| CI | `.github/workflows/` | [docs/workflow.md](docs/workflow.md) |
