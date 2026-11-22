# ns: guarda as notas no GitHub (commit e push de ~/notas), de qualquer pasta.
function ns --description 'Guarda as notas no GitHub'
    git -C ~/notas rev-parse --git-dir >/dev/null; or return 1
    if test -n "$(git -C ~/notas status --porcelain)"
        git -C ~/notas add -A
        and git -C ~/notas commit --quiet -m "notas: "(date +%F)
        or return 1
    end
    # Envia também o que ficou de um push que falhou antes (sem rede, por exemplo).
    if test -z "$(git -C ~/notas rev-list @{u}.. 2>/dev/null)"; and git -C ~/notas rev-parse @{u} >/dev/null 2>&1
        echo "Nada novo nas notas."
        return 0
    end
    git -C ~/notas push --quiet
    and echo "Notas guardadas."
end
