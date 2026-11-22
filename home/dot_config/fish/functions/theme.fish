# theme: troca o tema do desktop inteiro (Noctalia, Ghostty, niri, GTK, Qt, apps). docs/temas.md.
# `theme` abre a lista com a amostra das cores; `theme <variante>` troca direto. Super+T abre a lista.
function theme --description 'Troca o tema do desktop'
    set -l variantes (path basename -E ~/.config/noctalia/palettes/*.json)
    set -l atual (noctalia msg color-scheme-get 2>/dev/null | string split ' ')[2]
    set -l escolha $argv[1]
    if test -z "$escolha"
        set escolha (printf '%s\n' $variantes | fzf --with-shell='fish -c' --prompt="tema (atual: $atual)> " --height=100% \
            --preview='_devenv_theme_preview {}' --preview-window=right,55%)
        or return
    end
    if not contains -- $escolha $variantes
        echo "Tema desconhecido: $escolha. Opções: $variantes" >&2
        return 1
    end
    noctalia msg color-scheme-set custom $escolha >/dev/null
    and echo "Tema: $escolha"
end
