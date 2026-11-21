# 0009. Refatoração completa: menos camadas, Neovim no estilo craftzdog

Data: 2026-11-16 · Status: substituída pela [0010](0010-devenv-sem-nix-chezmoi-metapac.md)

## Contexto

O devenv cresceu por fases e acumulou peso. Os exemplos:

- O Neovim tem 27 plugins e uma camada própria de carga sob demanda com gerenciador (`pack.lua`, 312 linhas).
- O `AGENTS.md` global tem tabelas de modelo, effort e roteamento que entram em toda sessão de agente.
- O repo passa de 11 mil linhas de texto (`tests/metrics.sh`).

O Lucas quer repensar o ambiente inteiro. A referência para o fluxo do Neovim são as
[dotfiles do craftzdog](https://github.com/craftzdog/dotfiles): config plana, um `vim.pack.add` só, ui2, oil,
pickers no `;` e janelas no `s`.

## Decisão

- **A base continua.** Nix + home-manager por cima da distro (ADR 0001), com CI de instalação em Fedora, Ubuntu
  e Arch, rollback e sops (ADR 0007). A refatoração enxuga os módulos, sem trocar a fundação.
- **O Neovim é reescrito do zero**, no estilo craftzdog, pelos passos do `CONTEXT.md`. A config antiga sai no
  mesmo PR em que a nova entra, sem as duas lado a lado.
- **As áreas extras continuam:** notebooks, notas do Obsidian, debug (DAP) e dados (DuckDB).
- **O lockfile dos plugins continua no git.** Versões reproduzíveis, CI estável e `:PackRestore` valem mais do
  que seguir a spec à risca.
- **Uma área por PR, saindo da `dev`.** Cada área começa por um PR que só remove e depois recebe o que é novo.
  Ordem: regras dos agentes, Neovim, terminal (Ghostty, fish, tmux, fonte), desktop, temas, modelos e CI.
- **Medir antes e depois.** `just metrics` imprime linhas por área e o número de plugins. O baseline está abaixo.
  Uma área só está pronta quando passa no CI e fica menor que o baseline.

## Baseline

Medido em 2026-11-16, commit `8ad16a0`.

| Área | Arquivos | Linhas |
| --- | --- | --- |
| `modules` | 20 | 2121 |
| `config/nvim` | 21 | 1729 |
| `docs` | 19 | 1716 |
| `templates` | 145 | 3251 |
| `tests` | 10 | 437 |
| raiz (`AGENTS.md`, README, bootstrap, flake, justfile) | 5 | 393 |
| `.github` | 6 | 343 |
| `system` | 5 | 297 |
| `config/niri`, `noctalia`, `sway`, `i3`, `wm` | 7 | 481 |
| `themes` (sem as paletas JSON) | 1 | 268 |
| `keyboard` | 3 | 249 |
| `agents` | 5 | 228 |
| `hosts` | 2 | 55 |

Neovim: 27 plugins no lockfile. A abertura ficou em 26 e 29 ms (mediana de 7 execuções, duas rodadas de
`tests/nvim/startup.sh`) no notebook, com o Neovim `0.13.0-dev-1944`.

## Alternativas consideradas

- **Trocar o Nix pelo chezmoi, como o craftzdog:** config mais simples, mas perde o teste de instalação nas três
  distros, o rollback e o sops-nix.
- **Híbrido, com Nix só para CLIs e LSPs:** tira os módulos com opções, mas a troca de tema e os segredos dependem
  deles.
- **Adaptar o Neovim atual:** menos trabalho, mas mantém o `pack.lua`, que é a maior camada a cortar.
- **Um PR único na `feat/refactor`:** difícil de revisar e quebra o `git bisect`.

## Consequências

- O limite de abertura do CI (80 ms) continua. Sem a carga sob demanda, a abertura tende a subir. O PR do Neovim
  mede o tempo antes de remover o `pack.lua`.
- O `:Pack` some junto com o `pack.lua`. Atualizar e restaurar passam a ser `vim.pack.update()` direto.
- Cada PR atualiza o doc da sua área em `docs/`.
