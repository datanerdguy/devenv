# Atalhos do dia a dia. Rode `just` para ver a lista.

# Host padrão; troque com DEVENV_HOST=outro-host just switch
host := env("DEVENV_HOST", "fedora-laptop")

default:
    @just --list

# Aplica a configuração (ex.: just switch fedora-laptop)
switch target=host:
    home-manager switch --flake .#{{ target }}

# Constrói sem aplicar e mostra o que mudaria
diff target=host:
    nix build .#homeConfigurations.{{ target }}.activationPackage -o result
    nvd diff ~/.local/state/nix/profiles/home-manager result

# Atualiza as versões fixadas no flake.lock
update:
    nix flake update

# Formata os arquivos .nix
fmt:
    nix fmt

# Lint: formatação, Nix, shell scripts e workflows (o mesmo que o CI roda)
lint:
    nix fmt -- --ci
    statix check .
    shellcheck bootstrap.sh system/*.sh tests/*.sh tests/nvim/*.sh .githooks/*
    actionlint
    stylua --check --config-path config/nvim/.stylua.toml config/nvim tests/nvim

# Valida o flake inteiro
check:
    nix flake check

# Testa a instalação do zero num container (ex.: just test-container ubuntu:24.04)
test-container image="fedora:latest":
    tests/container.sh {{ image }}

# Commit guiado no padrão Conventional Commits
commit:
    cz commit

# Atualiza o Neovim (bob) e os plugins (vim.pack, com revisão antes de aplicar)
nvim-update:
    bob update --all
    nvim +PackUpdate

# Testa a config do Neovim: carga de todos os plugins e tempo de abertura
nvim-test:
    DEVENV_NVIM_TEST=1 nvim --headless -l tests/nvim/check.lua
    tests/nvim/startup.sh

# Lista as gerações (para rollback)
generations:
    home-manager generations
