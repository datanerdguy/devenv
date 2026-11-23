# theme: troca o tema do desktop inteiro (Noctalia, Ghostty, niri, GTK, Qt, apps). docs/themes.md.
# `theme` abre a lista com a amostra das cores; `theme <variante>` troca direto. Alt+Shift+T abre a lista.
function theme --description 'Troca o tema do desktop'
    set -l variants (path basename -E ~/.config/noctalia/palettes/*.json)
    set -l current (noctalia msg color-scheme-get 2>/dev/null | string split ' ')[2]
    set -l choice $argv[1]
    if test -z "$choice"
        set choice (printf '%s\n' $variants | fzf --with-shell='fish -c' --prompt="tema ❯ " --header="atual: $current" --height=100% \
            --preview='_devenv_theme_preview {}' --preview-window=right,55%)
        or return
    end
    if not contains -- $choice $variants
        echo "Tema desconhecido: $choice. Opções: $variants" >&2
        return 1
    end
    noctalia msg color-scheme-set custom $choice >/dev/null
    and echo "Tema: $choice"
end
