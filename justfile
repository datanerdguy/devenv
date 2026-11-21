# Atalhos do dia a dia. Rode `just` para ver a lista.

default:
    @just --list

# Liga os hooks do git (lint antes do commit, mensagem no padrão)
setup:
    git config core.hooksPath .githooks

# Aplica as configs de home/ (chezmoi)
apply:
    chezmoi apply

# Atualiza o sistema e instala o que falta nos grupos de packages/ (metapac)
sync:
    paru -Syu
    metapac sync
    packages/marca-deps.sh

# Remove o que não está nos grupos: mostra a lista e pede confirmação
clean:
    metapac clean

# O que mudaria nas configs e o que está instalado fora dos grupos
diff:
    chezmoi diff
    metapac unmanaged

# Lint: scripts, workflows e o mapa do teclado (o mesmo que o CI roda)
lint:
    shellcheck bootstrap.sh .githooks/* tests/*.sh packages/*.sh
    actionlint .github/workflows/*.yml
    python3 keyboard/render.py --check

# Regenera as imagens das camadas e o keyboard/README.md depois de salvar o .vil no Vial
keyboard:
    python3 keyboard/render.py

# Commit guiado no padrão Conventional Commits
commit:
    cz commit
