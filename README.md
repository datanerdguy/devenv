# devenv

O ambiente de desenvolvimento do Lucas no CachyOS (Arch). As configs vão pelo **chezmoi**, em links para este repo,
e os pacotes pelo **metapac**, em listas. As decisões ficam em [`docs/adr/`](docs/adr/), a começar pelo
[ADR 0010](docs/adr/0010-devenv-sem-nix-chezmoi-metapac.md). Os termos estão no [GLOSSARY](GLOSSARY.md).

## Máquina nova

```bash
git clone https://github.com/datanerdguy/devenv ~/devenv
cd ~/devenv
./bootstrap.sh
```

O bootstrap confere que a distro é Arch ou derivada, garante o `paru`, instala `chezmoi metapac age rbw jq`, traz a
chave age do Bitwarden (se o `rbw` estiver logado), aplica as configs e roda o `metapac sync`. Pode rodar de novo.

## Dia a dia

| Comando | O que faz |
| --- | --- |
| `just setup` | Liga os hooks do git (lint antes do commit, mensagem no padrão) |
| `just apply` | Aplica as configs de `home/` (`chezmoi apply`) |
| `just sync` | Atualiza o sistema (`paru -Syu`), instala o que falta nos grupos de `packages/` (`metapac sync`) e marca as dependências como dependências (`packages/marca-deps.sh`) |
| `just clean` | Remove o que não está nos grupos, depois de mostrar e pedir confirmação |
| `just noctalia-diff` | Mostra os ajustes feitos pela tela do Noctalia, para trazer ao repo |
| `just diff` | Mostra o que mudaria nas configs e o que está instalado fora dos grupos |
| `just lint` | shellcheck, actionlint e o mapa do teclado (o mesmo do CI) |
| `just keyboard` | Regenera as imagens das camadas depois de salvar no Vial ([keyboard/](keyboard/README.md)) |
| `just commit` | Commit guiado no padrão Conventional Commits |

## Estrutura

```text
.chezmoiroot      aponta para home/
home/             fonte do chezmoi: só links e templates
packages/         metapac: config.toml e groups/ (base, repo, linguagens, dados, api, shell, terminal, editor, agentes, git, desktop, teclado, debug, maquinas/<máquina>)
bootstrap.sh      máquina nova
justfile          comandos do dia a dia
keyboard/         Corne (Vial), a fonte é corne/corne.vil
agents/           Claude Code: regras globais, settings, statusline, MCP
docs/             workflow.md, agents.md, shell.md, desktop.md e adr/
```

## Áreas

O devenv é refeito uma área por PR. Base, agentes, shell, desktop e teclado estão prontos. Faltam terminal e temas
(os temas vêm a seguir), tmux, Neovim e dados.

| Área | Estado |
| --- | --- |
| Base (chezmoi, metapac, bootstrap, CI) | pronta |
| Agentes e git (Claude Code, delta, lazygit) | pronta, veja [docs/agents.md](docs/agents.md) |
| Desktop e teclado (niri, Noctalia, Vial) | pronta, veja [docs/desktop.md](docs/desktop.md) |
| Shell (fish) | pronta, veja [docs/shell.md](docs/shell.md) |
| Terminal e temas, tmux, Neovim | a fazer, pelo Lucas |
| Dados | a fazer |

## Contribuindo

Mudanças vão para a `dev` por PR e só depois para a `main`, com Conventional Commits. Veja
[`docs/workflow.md`](docs/workflow.md). Para trabalhar no repo, rode `just setup` uma vez.
