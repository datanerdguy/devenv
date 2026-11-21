# 0010. Devenv refeito sem Nix, com chezmoi e metapac

Data: 2026-11-21 · Status: aceita

## Contexto

O Lucas trocou para o CachyOS (derivada do Arch, hostname `cachyos`): niri + Noctalia pelo pacote
`cachyos-niri-noctalia`, btrfs com snapper, snap-pac e limine, Intel com NVIDIA MX110 (driver 580xx, uso por
`prime-run`), 7,6 GB de RAM e disco sem LUKS.

Ele quer um ambiente leve, que entenda de ponta a ponta e que outras distros possam usar depois por listas de
pacotes. O Nix + home-manager (ADR 0001) pesa nessa máquina e esconde as configs atrás de módulos. A decisão
foi tomada numa sessão de perguntas e respostas e vale para o repo inteiro: o devenv é refeito do zero, uma
área por PR.

## Decisão

**Base.**

- Sem Nix. Os ADRs 0001, 0003, 0005, 0006, 0007 e 0009 ficam substituídos por este.
- **chezmoi** leva as configs, em modo de links (`mode = "symlink"`), então editar o repo já vale. A fonte é
  `home/` (`.chezmoiroot`).
- **metapac** leva os pacotes, em `packages/`. O `~/.config/metapac` é um link para essa pasta. Os grupos
  ficam em `packages/groups/` e cada máquina escolhe os seus em `hostname_groups`.
- O `bootstrap.sh` põe tudo de pé numa máquina nova e é idempotente.

**Segredos.** chezmoi com age. A chave fica em `~/.config/chezmoi/key.txt` e é guardada no Bitwarden
(item `devenv-age-key`), de onde o `rbw` a traz. Tokens de valor vêm pelo `rbw` na hora de usar, nunca em arquivo.

**Versões por projeto.**

- rustup, a toolchain do Go e o uv escolhem a versão dentro de cada projeto.
- mise só entra para Node, Erlang/Elixir, Java e Lua, e a versão vem do arquivo do projeto.
- Exceção: o mise instala um pacote da máquina quando não há pacote na distro nem no AUR. Hoje só o Expert
  (`github:elixir-lang/expert`), que só existe no GitHub.

**Ferramenta do projeto.** A ferramenta que o projeto declara vence a da lista. O metapac instala só o padrão
da máquina (LSPs, formatadores e linters), usado quando o projeto não traz o seu.

**Linguagens, LSPs e formatadores.** Tudo pelo metapac, em `packages/groups/linguagens.toml`. Sem Mason.

| Linguagem | LSP | Formatador e linter |
| --- | --- | --- |
| Rust | rust-analyzer (componente do rustup) | rustfmt, clippy (rustup) |
| Go | gopls | gofumpt, golangci-lint |
| Python | ty | ruff |
| TypeScript, JavaScript | vtsls | prettier, eslint |
| Erlang | elp | do projeto (`rebar3`) |
| Elixir | Expert (mise) | `mix format` (do projeto) |
| Lua | lua-language-server | stylua, selene |
| C, C++ | clangd (pacote `clang`) | clang-format (`clang`), cmake, ninja |
| Java | jdtls | google-java-format |
| Assembly | asm-lsp | nasm |
| HTML | vscode-html-languageserver, superhtml | prettier |
| CSS, Tailwind | vscode-css-languageserver, tailwindcss-language-server | prettier |
| JSON | vscode-json-languageserver | prettier |
| YAML | yaml-language-server | prettier |
| TOML | tombi | tombi |
| Markdown | marksman | markdownlint-cli2 |
| Bash | bash-language-server | shfmt, shellcheck |
| fish | fish-lsp | `fish_indent` (fish) |
| Dockerfile | dockerfile-language-server | hadolint |
| just | just-lsp | `just --fmt` |
| htmx | htmx-lsp (cargo) | |

O `basedpyright` fica instalado como segunda opção do Python, mas o padrão é o `ty`.

**DAP.** Os debuggers entram em `packages/groups/debug.toml`, todos comentados (`codelldb`, `delve`,
`python-debugpy`, `gdb`, `lldb`). O Lucas tira o comentário do que precisar.

**Aparência.**

- Temas trocáveis por um script `theme` próprio, só com as variantes escuras oficiais: Nord (padrão),
  Everforest, Rosé Pine, Catppuccin, Dracula e Kanagawa.
- Fonte BlexMono Nerd Font.
- fish novo: vi mode, tide via fisher, zoxide + fd + fzf num atalho, abbr e nenhuma config do CachyOS. O cursor
  é sempre bloco e a cor por modo sai do tema. tmux 3.8.

**Estrutura do repo.**

```text
.chezmoiroot      aponta para home/
home/             fonte do chezmoi (só links e templates)
packages/         config.toml e groups/ do metapac
bootstrap.sh      máquina nova
justfile          comandos do dia a dia
keyboard/         Corne (Vial)
agents/AGENTS.md  regras globais dos agentes
docs/adr/         decisões
```

**CI.** Container `archlinux:latest` com `--hostname ci`. O job `lint` roda `just lint`. O job `apply` roda o
`bootstrap.sh` com um usuário comum e depois `tests/smoke.sh`. O grupo `ci` do metapac só tem `base` e `repo`.

**Ordem das áreas.** Base (este ADR), agentes, shell, terminal (com o tema), tmux, Neovim, desktop, teclado e
dados (a repensar). O Lucas escreve shell, terminal, tmux e Neovim; o agente ajuda quando ele pedir.

## Alternativas consideradas

- **A. Manter o Nix + home-manager:** versões travadas e teste em três distros, mas pesado nessa máquina, com
  as configs escondidas em módulos. Descartado.
- **C. Híbrido (Nix só para CLIs, chezmoi para as configs):** mantém o peso do Nix e dois jeitos de instalar.
  Descartado.
- **stow:** só faz links, não tem templates nem segredos. O chezmoi faz os links e o resto.
- **decman e aconfmgr:** só Arch e amarram o repo a ele. O metapac aceita outros gerenciadores e outras
  distros depois, só trocando as listas.
- **zellij:** o tmux já resolve e o Lucas o conhece.
- **starship:** o tide, do fish, é mais leve e nativo do shell.
- **hydro:** o prompt é mais simples do que o Lucas quer; ficou o tide.
- **Mason:** instala LSPs fora da lista e da distro. Os pacotes pelo metapac ficam declarados e atualizam junto
  com o sistema.
- **basedpyright como padrão:** pesa mais que o `ty`. Fica como segunda opção.
- **biome:** o prettier + eslint cobrem o que ele cobriria e os projetos já os declaram.

## Consequências

- Perde as versões travadas do `flake.lock` e o teste de instalação em Fedora, Ubuntu e Arch. O CI só testa o Arch.
- O snap-pac tira um snapshot do btrfs a cada transação do pacman, então ele cobre o rollback dos pacotes.
- O disco não é cifrado. Segredo em arquivo com permissão 0600 fica legível sem LUKS, para quem tiver o disco.
  A chave age e os arquivos cifrados valem só contra olhos no repo, não contra o disco.
- `metapac clean` remove tudo o que não está na lista. Por isso o grupo `maquinas/cachyos` guarda o que o
  instalador do CachyOS deixou e se regera com `metapac unmanaged`.
- Outras distros entram depois com os seus grupos e backends no `config.toml`.
