# Busca nos manuais: digite o nome ou o assunto, veja o manual ao lado, e o Enter abre no Neovim.
# O Ctrl+G faz isso para as pastas; o Ctrl+K faz isto (o K do vim abre o manual).
function mf --description 'Busca e abre um manual'
    # man -k lista "nome (seção) - descrição"; vira seção, nome e descrição separados por tab.
    set -l page (man -k . 2>/dev/null \
        | sed -E 's/^([^ ]+) +\(([^)]+)\) +- (.*)$/\2\t\1\t\3/' \
        | fzf --delimiter=\t --with-nth=2,1,3 --tiebreak=begin,chunk --height=90% --prompt='man> ' --query="$argv" \
            --preview='man {1} {2} 2>/dev/null | col -bx | bat --language man --plain --color=always' \
            --preview-window=right,60%)
    or return
    set -l fields (string split \t -- $page)
    man $fields[1] $fields[2]
end
