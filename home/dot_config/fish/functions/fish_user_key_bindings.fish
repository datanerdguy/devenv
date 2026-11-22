# Roda depois que o fish carrega o vi mode, então os atalhos daqui não são apagados.
function fish_user_key_bindings
    # fzf: Ctrl+R no histórico, Ctrl+T para colar um arquivo.
    _devenv_source_cached fzf --fish

    for modo in insert default
        # Ctrl+G: ir para uma pasta (zoxide + fd + fzf).
        bind -M $modo ctrl-g _devenv_jump
        # Ctrl+K: buscar e abrir um manual (mf).
        bind -M $modo ctrl-k 'mf (commandline --current-token); commandline --function repaint'
    end
end
