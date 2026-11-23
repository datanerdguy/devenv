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

# Lint: scripts, workflows, grupos do metapac, mapa do teclado e, se instalados, niri, paletas, tmux e Neovim (o mesmo do CI)
lint:
    shellcheck bootstrap.sh .githooks/* tests/*.sh packages/*.sh agents/*.sh home/dot_local/bin/*
    # Estilo do repo (.stylua.toml e .editorconfig), o mesmo que o Neovim aplica ao salvar.
    if command -v stylua >/dev/null; then stylua --check home/dot_config/nvim tests/*.lua; fi
    if command -v shfmt >/dev/null; then shfmt -d bootstrap.sh tests/*.sh packages/*.sh agents/*.sh home/dot_local/bin/*; fi
    python3 packages/checar.py
    python3 tests/checar-docs.py
    actionlint .github/workflows/*.yml
    python3 keyboard/render.py --check
    # O niri só existe na máquina com o grupo desktop; no CI ele entra pelo smoke do CI completo.
    if command -v niri >/dev/null; then niri validate -c home/dot_config/niri/config.kdl; fi
    # As paletas saem dos temas do Ghostty (grupo terminal); sem ele, quem confere é o smoke do CI completo.
    if [ -d /usr/share/ghostty/themes ]; then python3 temas/gerar.py --check; fi
    if command -v tmux >/dev/null; then tests/checar-tmux.sh home/dot_config/tmux/tmux.conf; fi
    tests/checar-modelos.sh
    if command -v nvim >/dev/null; then tests/checar-nvim.sh home/dot_config/nvim; fi

# Ajustes feitos pela tela do Noctalia (Alt+Shift+,): o que quiser manter, copie para home/dot_config/noctalia/config.toml
noctalia-diff:
    @cat ~/.local/state/noctalia/settings.toml 2>/dev/null || echo "Nenhum ajuste feito pela tela do Noctalia."

# Regenera as imagens das camadas e o keyboard/README.md depois de salvar o .vil no Vial
keyboard:
    python3 keyboard/render.py

# Commit guiado no padrão Conventional Commits
commit:
    cz commit
