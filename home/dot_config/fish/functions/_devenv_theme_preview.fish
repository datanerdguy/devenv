# Amostra de uma variante para a lista do theme: as 16 cores do terminal e as de destaque da interface.
function _devenv_theme_preview -a variante
    set -l arquivo ~/.config/noctalia/palettes/$variante.json
    set -l t (jq -r '.dark.terminal | .background, .foreground, (.normal | .[]), (.bright | .[])' $arquivo)
    set -l ui (jq -r '.dark | .mPrimary, .mSecondary, .mTertiary' $arquivo)
    set_color -b $t[1] $t[2]
    printf '\n  %s  \n\n' $variante
    for linha in 3 11
        printf '  '
        for i in (seq $linha (math $linha + 7))
            set_color -b $t[$i]
            printf '    '
        end
        set_color normal
        printf '\n'
    end
    printf '\n  destaques: '
    for cor in $ui
        set_color -b $cor
        printf '      '
        set_color normal
        printf ' '
    end
    printf '\n'
    set_color normal
end
