# devenv

O ambiente de desenvolvimento do Lucas no CachyOS (Arch). As configs vão pelo **chezmoi**, em links para este repo,
e os pacotes pelo **metapac**, em listas. O porquê de cada área fica no doc dela, na seção "Por que assim".

## Máquina nova

```bash
git clone https://github.com/datanerdguy/devenv ~/devenv
cd ~/devenv
./bootstrap.sh
```

O bootstrap confere que a distro é Arch ou derivada, garante o `paru`, instala `rustup chezmoi metapac age rbw jq`, traz a
chave age do Bitwarden (se o `rbw` estiver logado), aplica as configs e roda o `metapac sync`. Pode rodar de novo.

## Dia a dia

| Comando | O que faz |
| --- | --- |
| `just setup` | Liga os hooks do git (lint antes do commit, mensagem no padrão) |
| `just apply` | Aplica as configs de `home/` (`chezmoi apply`) |
| `just sync` | Atualiza o sistema (`paru -Syu`), instala o que falta nos grupos de `packages/` (`metapac sync`) e marca as dependências como dependências (`packages/mark-deps.sh`) |
| `just clean` | Remove o que não está nos grupos, depois de mostrar e pedir confirmação |
| `just noctalia-diff` | Mostra os ajustes feitos pela tela do Noctalia, para trazer ao repo |
| `just diff` | Mostra o que mudaria nas configs e o que está instalado fora dos grupos |
| `just lint` | shellcheck, actionlint, o estilo do Lua e dos scripts, os grupos do metapac, o mapa do teclado e, se instalados, o niri, as paletas, o tmux e o Neovim (o mesmo do CI) |
| `just keyboard` | Regenera as imagens das camadas depois de salvar no Vial ([keyboard/](keyboard/README.md)) |
| `just commit` | Commit guiado no padrão Conventional Commits |
| `just promote` | Leva a `main` até a `dev` do GitHub (só avança, nunca apaga) |

## Estrutura

```text
.chezmoiroot      aponta para home/
home/             fonte do chezmoi: só links e templates
packages/         metapac: config.toml (grupos de cada máquina) e groups/ (o topo de cada arquivo diz para que serve)
bootstrap.sh      máquina nova
justfile          comandos do dia a dia
tests/            smoke.sh: o que o bootstrap deve deixar pronto (roda no CI)
.github/          CI e modelo de PR
themes/            gerador das paletas dos temas (generate.py)
wallpapers/       papéis de parede (ligada em ~/Pictures/Wallpapers)
templates/          configs para copiar num projeto novo (pyproject.toml, .golangci.yml...), veja templates/README.md
keyboard/         Corne (Vial), a fonte é corne/corne.vil
agents/           Claude Code: regras globais, settings, statusline, MCP
docs/             workflow.md, agents.md, shell.md, tmux.md, neovim.md, desktop.md, themes.md e data.md
```

## Áreas

O devenv foi refeito uma área por vez; todas estão prontas.

| Área | Estado |
| --- | --- |
| Base (chezmoi, metapac, bootstrap, CI) | pronta |
| Agentes e git (Claude Code, delta, lazygit) | pronta, veja [docs/agents.md](docs/agents.md) |
| Desktop e teclado (niri, Noctalia, Vial) | pronta, veja [docs/desktop.md](docs/desktop.md) |
| Shell (fish) | pronta, veja [docs/shell.md](docs/shell.md) |
| Temas (`theme`, Alt+Shift+T) | pronta, veja [docs/themes.md](docs/themes.md) |
| tmux (sesh, workmux) | pronta, veja [docs/tmux.md](docs/tmux.md) |
| Neovim | pronta: nativo primeiro, busca, explorer, LSP, treesitter, Claude no editor, veja [docs/neovim.md](docs/neovim.md) |
| Dados (Podman, duckdb, visidata, harlequin) | pronta, veja [docs/data.md](docs/data.md) |

## Por que assim

- Sem Nix: pesava nesta máquina e escondia as configs atrás de módulos. Aqui cada config é o arquivo do programa.
- chezmoi, e não stow: além dos links, faz templates e segredos. metapac, e não decman ou aconfmgr: aceita outros
  gerenciadores e outras distros, só trocando as listas.
- Segredos com age. A chave fica em `~/.config/chezmoi/key.txt` e no Bitwarden (item `devenv-age-key`); tokens vêm
  do `rbw` na hora. O disco não é cifrado: o age protege do repo, não de quem tiver o disco.
- A versão da linguagem é a do projeto (rustup, Go, uv, mise), e a ferramenta do projeto vence a da lista. LSPs e
  formatadores vêm do metapac, sem Mason, para ficarem declarados e atualizarem com o sistema.
- O `metapac clean` remove o que não está na lista. Por isso o `machines/cachyos` guarda o que o instalador deixou,
  e o `packages/mark-deps.sh` devolve as dependências a dependências depois de cada sync.

## Contribuindo

Mudanças vão direto para a `dev`, sem PR; o `just promote` leva a `dev` para a `main`. Commits no padrão
Conventional Commits. Veja
[`docs/workflow.md`](docs/workflow.md). Para trabalhar no repo, rode `just setup` uma vez.
