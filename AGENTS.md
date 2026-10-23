# devenv: instruções para agentes de código

Este repo é o ambiente de desenvolvimento do Lucas: Nix flakes + home-manager por cima da distro
(Fedora, Ubuntu, Arch), com desktop niri + Noctalia, Neovim, tmux, agentes e temas trocáveis.
Comece pelo [README](README.md); as decisões e o porquê ficam em [`docs/adr/`](docs/adr/).

## Regras do projeto

- **Idioma:** docs, comentários, mensagens de commit e títulos de PR em português (pt-BR), frases curtas e simples.
- **Desempenho importa:** tudo leve. Plugins do Neovim carregam sob demanda, e o CI mede a abertura
  (`tests/nvim/startup.sh`). Antes de acrescentar uma ferramenta, veja se uma que já existe resolve.
- **Pesquisar antes de criar:** área nova (ferramenta, módulo, fluxo) começa com opções comparadas e uma
  recomendação para o Lucas decidir. Não implemente uma área nova sem essa decisão.
- **Apps gráficos não vêm do Nix:** os que precisam da GPU vêm da distro (`system/<distro>.sh`) ou do Flathub
  (`modules/apps`). Do Nix vêm CLIs, LSPs e configs. O Vial é a exceção.
- **Segredos:** nunca no repo nem em texto plano. Vão cifrados em `secrets/<host>.yaml` (sops + age; [docs/secrets.md](docs/secrets.md)).
- **Agentes:** assinatura Claude Pro, sem chave de API. Nada que dependa de API key paga.
- **Documente tudo:** mudou algo que o usuário vê, atualize o doc da área em `docs/` (e o README se for uma área nova).

## Fluxo de git

- Branch de trabalho (`feat/*`, `fix/*`, `chore/*`, `docs/*`) saindo da `dev` → PR para a `dev` (squash) →
  PR `dev` → `main` (merge commit, título `chore(release): ...`). Detalhes em [docs/workflow.md](docs/workflow.md).
- Conventional Commits, validados pelo commitizen. O título do PR também precisa passar (`cz check --message "<título>"`).
- Faça commit dentro do `nix develop`: os hooks de `.githooks/` rodam o lint e validam a mensagem.
- Use o modelo de PR (`.github/pull_request_template.md`): O que muda, Como testei, Notas.
- O Lucas faz o merge. Não mexa nas regras do repositório.

## Comandos

| Comando | Para quê |
| --- | --- |
| `nix develop` | shell com todas as ferramentas do repo |
| `just lint` | nixfmt, statix, shellcheck, actionlint, stylua e o gerador do teclado (igual ao CI) |
| `just check` | `nix flake check` |
| `just desktop-check` | valida as configs do niri, sway, i3 e kanata |
| `just switch [host]` | aplica a configuração nesta máquina |
| `just test-container <imagem>` | instalação do zero num container (ex.: `ubuntu:26.04`) |
| `just keyboard` | refaz as imagens das camadas do Corne depois de mudar o `.vil` |

Teste do Neovim: `DEVENV_NVIM_TEST=1 nvim --headless -l tests/nvim/check.lua` (carrega todos os plugins).

## Onde fica cada coisa

| Área | Código | Doc |
| --- | --- | --- |
| Módulos do home-manager | `modules/<área>/default.nix` (opções em `devenv.<área>`) | README |
| Máquinas | `hosts/<host>.nix` | README |
| Root por distro | `bootstrap.sh`, `system/<distro>.sh` | [docs/desktop.md](docs/desktop.md) |
| Neovim | `config/nvim/` (vim.pack, `lua/devenv/plugins/*.lua`) | [docs/neovim.md](docs/neovim.md) |
| Dados (SQL, CSV) | `modules/cli`, `config/nvim/lua/devenv/data.lua` | [docs/data.md](docs/data.md) |
| tmux | `modules/tmux/tmux.conf` | [docs/tmux.md](docs/tmux.md) |
| Desktop | `config/niri`, `config/noctalia`, `config/sway`, `config/i3`, `config/wm` | [docs/desktop.md](docs/desktop.md), [docs/apps.md](docs/apps.md) |
| Temas | `themes/<id>/palette.json`, `modules/theme` (comando `theme`) | [docs/themes.md](docs/themes.md) |
| Agentes | `modules/agents`, `agents/` (o `agents/AGENTS.md` é o global, instalado em `~/.config/agents`) | [docs/agents.md](docs/agents.md) |
| Modelos de projeto | `templates/`, `copier.yml`, `modules/templates` (comando `new`) | [docs/templates.md](docs/templates.md) |
| Segredos | `modules/secrets`, `secrets/` | [docs/secrets.md](docs/secrets.md) |
| Teclado | `keyboard/` (`corne/corne.vil` é a fonte) | [keyboard/README.md](keyboard/README.md) |
| CI | `.github/workflows/`, `tests/` | [docs/workflow.md](docs/workflow.md) |

As configs em `config/` são links para o repo (editar já vale). Mudança em módulo Nix só vale depois do `just switch`.
