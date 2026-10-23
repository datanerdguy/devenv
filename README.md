# devenv

Ambiente de desenvolvimento reproduzível com **Nix flakes + home-manager**, para Fedora, Ubuntu, Arch e derivadas.

Foco: ML/IA/LLM, dados, fluxo guiado pelo teclado (terminal, Neovim, niri), code agents. O plano completo está no documento de proposta; as decisões ficam em [`docs/adr/`](docs/adr/).

## Máquina nova

```bash
git clone https://github.com/datanerdguy/devenv ~/devenv
cd ~/devenv
./bootstrap.sh fedora-laptop
```

O bootstrap faz três coisas:

1. Instala pela distro o que precisa de root (`system/<distro>.sh`): Ghostty, fish, bubblewrap (sandbox dos agentes), o desktop (niri + Noctalia), regras udev dos teclados e o driver NVIDIA se houver placa.
2. Instala o Nix, se faltar.
3. Aplica a configuração do host com o home-manager na versão fixada no `flake.lock`.

Antes de rodar, ajuste o usuário em [`hosts/fedora-laptop.nix`](hosts/fedora-laptop.nix). Nome, e-mail e tokens ficam cifrados em `secrets/` ([`docs/secrets.md`](docs/secrets.md)).

## Dia a dia

| Comando | O que faz |
| --- | --- |
| `just switch` | Aplica a configuração |
| `just diff` | Mostra o que mudaria, pacote a pacote, sem aplicar |
| `just update` | Atualiza as versões fixadas no `flake.lock` |
| `just lint` | Formatação, statix, shellcheck, actionlint e stylua (o mesmo do CI) |
| `just check` | Valida o flake inteiro |
| `just test-container` | Instala do zero num container e roda os testes |
| `just commit` | Commit guiado no padrão Conventional Commits |
| `just nvim-update` | Atualiza o Neovim (bob) e os plugins (com revisão) |
| `just nvim-test` | Testa a config do Neovim e o tempo de abertura |
| `just agents-update` | Atualiza só os agentes de código |
| `just desktop-check` | Valida as configs do niri, sway, i3 e kanata |
| `just keyboard` | Regenera as imagens das camadas do teclado depois de salvar no Vial ([keyboard/](keyboard/README.md)) |
| `just noctalia-diff` | Mostra os ajustes feitos pela tela do Noctalia |
| `theme <nome>` | Troca o tema de tudo (`Super+T` mostra a lista) |
| `new python meu-projeto api` | Cria um projeto pronto a partir dos modelos ([`docs/templates.md`](docs/templates.md)) |
| `just generations` | Lista as gerações para rollback |

## Contribuindo

Mudanças vão para a branch `dev` por PR e só depois para a `main`. Commits seguem Conventional Commits (validados pelo commitizen). Todo PR passa por lint, build e instalação do zero em containers Fedora, Ubuntu e Arch. Detalhes em [`docs/workflow.md`](docs/workflow.md).

Para trabalhar no repo: `nix develop` (ou `direnv allow`), que traz as ferramentas e liga os git hooks.

## Estrutura

```text
flake.nix / flake.lock   entrada única, versões fixadas
hosts/                   uma configuração por máquina (ci.nix é o host de teste)
modules/                 módulos liga/desliga (devenv.<nome>.enable)
  cli/                   ripgrep, fd, fzf, bat, eza, zoxide, atuin, direnv, yazi...
  shell/                 fish + starship (bash continua como shell de login)
  git/                   git, delta, lazygit, gh
  terminal/              configuração do Ghostty
  nvim/                  Neovim pelo bob, LSPs e ferramentas, link da config
  tmux/                  tmux sem plugins + sesh
  agents/                Claude Code, Codex, Gemini CLI, opencode, workmux, tokscale
  local-models/          Ollama opcional (desligado por padrão)
  desktop/               niri, Noctalia, sway/i3 opcionais, kanata, Vial
  apps/                  Flatpaks (nix-flatpak), Flameshot, apps padrão
  theme/                 comando `theme` (troca o tema de todos os apps)
  templates/             comando `new` (cria projetos a partir dos modelos)
themes/                  as paletas e os papéis de parede de cada tema
templates/ + copier.yml  modelos de projeto (Python, Go, Rust e Phoenix)
config/                  configs ligadas em ~/.config (nvim, niri, noctalia, sway, i3)
keyboard/                layout do Corne (Vial), imagens das camadas e o gerador (render.py)
agents/                  AGENTS.md, skills e scripts dos agentes
system/                  scripts de root por distro
tests/                   testes de fumaça, do Neovim, do desktop, dos modelos e instalação em container
.githooks/               hooks de lint e de mensagem de commit
.github/workflows/       CI, release e atualização semanal do flake.lock
docs/                    fluxo de trabalho e ADRs (decisões e o porquê)
```

## Fases

- [x] 1. Fundação: flake, home-manager, CLIs, git, fish, Ghostty
- [x] 2. Neovim (bob nightly 0.13, vim.pack): veja [`docs/neovim.md`](docs/neovim.md)
- [x] 3. tmux + sesh: veja [`docs/tmux.md`](docs/tmux.md)
- [x] 4. Desktop: niri + Noctalia, sway/i3, kanata, Corne: veja [`docs/desktop.md`](docs/desktop.md) e [`docs/apps.md`](docs/apps.md)
- [x] 5. Temas trocáveis (Everforest, Rosé Pine, Catppuccin, Dracula): veja [`docs/themes.md`](docs/themes.md)
- [x] 6. Agentes: workmux, roteamento, métricas, docs MCP: veja [`docs/agents.md`](docs/agents.md)
- [x] 7. Modelos de projeto (`new`): Python (lib, api, llm, data, ml, fastapi-htmx, django, streamlit), Go (cli, service, htmx), Rust (bin, lib) e Phoenix. Veja [`docs/templates.md`](docs/templates.md)
- [x] 8. Portabilidade: Arch e derivadas, Ubuntu 26.04 no CI, segredos com sops-nix: veja [`docs/secrets.md`](docs/secrets.md)
- [x] Dados no terminal: harlequin, tabiew e DuckDB (também pelo Neovim): veja [`docs/data.md`](docs/data.md)
