# ns: guarda as notas no GitHub (commit e push de ~/notas), de qualquer pasta.
function ns --description 'Guarda as notas no GitHub'
    if test -z "$(git -C ~/notas status --porcelain)"
        echo "Nada novo nas notas."
        return 0
    end
    git -C ~/notas add -A
    and git -C ~/notas commit --quiet -m "notas: "(date +%F)
    and git -C ~/notas push --quiet
    and echo "Notas guardadas."
end
