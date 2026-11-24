# devenv: instruções para agentes de código

Este repo é o ambiente de desenvolvimento do Lucas no CachyOS (Arch): configs pelo chezmoi (`home/`) e pacotes
pelo metapac (`packages/`). Comece pelo [README](README.md); o porquê de cada área fica no doc dela.

## Regras do projeto

- **Idioma:** docs, comentários, mensagens de commit e títulos de PR em português (pt-BR), frases curtas e simples.
- **Desempenho importa:** tudo leve. Antes de acrescentar uma ferramenta, veja se uma que já existe resolve.
- **Pesquisar antes de criar:** área nova (ferramenta, módulo, fluxo) começa com opções comparadas e uma
  recomendação para o Lucas decidir. Não implemente uma área nova sem essa decisão.
- **Pacote novo vai no grupo certo do metapac** (`packages/groups/`): o comentário no topo de cada arquivo diz para
  que serve o grupo. Grupo novo entra em uma máquina e no `ci-full` de `packages/config.toml`.
  Um pacote aparece uma vez só entre todos os grupos. O que é só desta máquina fica em `machines/<máquina>`.
- **Configs em `home/` são links para o repo** (editar já vale). O chezmoi cria os links no `just apply`.
- **Versões por projeto:** rustup, Go, uv e mise (Node, Erlang/Elixir, Lua, Java) escolhem a versão dentro de cada
  projeto. A ferramenta do projeto vence a da lista de pacotes. Fora de projeto, valem as versões globais mais
  novas do mise (`packages/groups/languages.toml`).
- **As áreas shell, terminal e temas, tmux e Neovim são do Lucas.** O agente só ajuda quando ele pedir.
- **Segredos:** nunca no repo nem em texto plano. Cifrados com chezmoi + age; tokens pelo `rbw` na hora.
  O disco não é cifrado, então arquivo com segredo fica com permissão 0600.
- **Agentes:** assinatura Claude Pro, sem chave de API. Nada que dependa de API key paga.
- **Documente tudo:** mudou algo que o usuário vê, atualize o README e o doc da área.

## Checagens

- `just lint` (também no hook de commit e no CI): shellcheck, stylua e shfmt, os grupos do metapac
  (`packages/check.py`), workflows, o mapa do teclado e, se instalados, niri, paletas, tmux e Neovim
  (`tests/check-nvim.sh`: sem aviso ao abrir, LSPs instalados, parsers do treesitter e lua_ls sem aviso).
- `tests/smoke.sh` (no CI, numa máquina nova): o bootstrap deixa tudo pronto, e nenhum programa escreve no repo
  pelos links do chezmoi. Se um programa acrescenta uma linha na config dele, a linha já precisa estar no repo.
- Uma checagem nova precisa falhar no erro que ela previne: rode contra o erro antes de confiar.
- Docs dizem o que o código faz: confira no arquivo antes de escrever.

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
| Pacotes (metapac) | `packages/config.toml`, `packages/groups/` | [README](README.md) |
| Máquina nova | `bootstrap.sh`, `tests/smoke.sh` | README |
| Shell (fish) | `home/dot_config/fish/` | [docs/shell.md](docs/shell.md) |
| Neovim | `home/dot_config/nvim/` | [docs/neovim.md](docs/neovim.md) |
| tmux | `home/dot_config/tmux/`, `home/dot_config/sesh/`, `home/dot_config/workmux/` | [docs/tmux.md](docs/tmux.md) |
| Desktop | `home/dot_config/niri/`, `home/dot_config/noctalia/` | [docs/desktop.md](docs/desktop.md) |
| Temas | `themes/generate.py`, `home/dot_config/noctalia/palettes/` e `templates/` | [docs/themes.md](docs/themes.md) |
| Teclado | `keyboard/` (`corne/corne.vil` é a fonte) | [keyboard/README.md](keyboard/README.md), [docs/desktop.md](docs/desktop.md) |
| Agentes e git | `agents/`, `home/dot_claude/`, `home/dot_config/git/` | [docs/agents.md](docs/agents.md) |
| Dados e containers | `packages/groups/data.toml`, `packages/groups/containers.toml` | [docs/data.md](docs/data.md) |
| Modelos de projeto | `templates/` | [templates/README.md](templates/README.md) |
| CI | `.github/workflows/` | [docs/workflow.md](docs/workflow.md) |
