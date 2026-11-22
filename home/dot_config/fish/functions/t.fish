function t --description 'Abre ou volta para uma sessão do tmux (sesh)'
    set -l escolha (sesh list --icons | fzf --ansi --no-sort --prompt 'sessão> ' \
        --preview 'sesh preview {}' --preview-window right:55%)
    or return
    sesh connect $escolha
end
