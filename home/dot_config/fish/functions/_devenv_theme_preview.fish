# Amostra de uma variante para a lista do theme: as 16 cores do terminal e as de destaque da interface.
function _devenv_theme_preview --argument-names variant
    set -l file ~/.config/noctalia/palettes/$variant.json
    set -l t (jq -r '.dark.terminal | .background, .foreground, (.normal | .[]), (.bright | .[])' $file)
    set -l ui (jq -r '.dark | .mPrimary, .mSecondary, .mTertiary' $file)
    set_color -b $t[1] $t[2]
    printf '\n  %s  \n\n' $variant
    for row in 3 11
        printf '  '
        for i in (seq $row (math $row + 7))
            set_color -b $t[$i]
            printf '    '
        end
        set_color normal
        printf '\n'
    end
    printf '\n  destaques: '
    for color in $ui
        set_color -b $color
        printf '      '
        set_color normal
        printf ' '
    end
    printf '\n'
    set_color normal
end
