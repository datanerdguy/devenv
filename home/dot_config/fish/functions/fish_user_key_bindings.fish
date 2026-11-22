# Roda depois que o fish carrega o vi mode, então os atalhos daqui não são apagados.
function fish_user_key_bindings
    # fzf: Ctrl+R no histórico, Ctrl+T para colar um arquivo.
    _devenv_source_cached fzf --fish

    # Ctrl+G: ir para uma pasta (zoxide + fd + fzf).
    bind -M insert ctrl-g _devenv_jump
    bind -M default ctrl-g _devenv_jump

    # Ctrl+K: buscar e abrir um manual (mf).
    bind -M insert ctrl-k 'mf (commandline --current-token); commandline --function repaint'
    bind -M default ctrl-k 'mf (commandline --current-token); commandline --function repaint'
end
