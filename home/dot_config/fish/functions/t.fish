function t --description 'Abre ou volta para uma sessão do tmux (sesh)'
    # Ocupa a tela toda; no P s, o popup do tmux dá a borda.
    set -l choice (sesh list --icons | fzf --ansi --no-sort --height=100% --border=none --prompt='sessão ❯ ' \
        --header='Ctrl-d fecha a sessão' \
        --bind='ctrl-d:execute-silent(tmux kill-session -t {2..})+reload(sesh list --icons)' \
        --preview='sesh preview {}' --preview-window=right,45%,border-left,noinfo)
    or return
    sesh connect $choice
end
