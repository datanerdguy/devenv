function t --description 'Abre ou volta para uma sessão do tmux (sesh)'
    # --color=16: as cores do terminal, que seguem o tema. No P s, o popup do tmux já dá a borda.
    set -l escolha (sesh list --icons | fzf --ansi --no-sort --height=100% --layout=reverse --border=none \
        --color=16 --prompt '❯ ' --pointer '▌' --gutter ' ' --no-scrollbar --info inline-right \
        --header 'Ctrl-d fecha a sessão' \
        --bind 'ctrl-d:execute-silent(tmux kill-session -t {2..})+reload(sesh list --icons)' \
        --preview 'sesh preview {}' --preview-window 'right,45%,border-left,noinfo')
    or return
    sesh connect $escolha
end
