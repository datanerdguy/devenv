# Roda depois que o fish carrega o vi mode, então os atalhos daqui não são apagados.
function fish_user_key_bindings
    # fzf: Ctrl+R no histórico, Ctrl+T para colar um arquivo.
    _devenv_source_cached fzf --fish

    # Ctrl+G: ir para uma pasta (zoxide + fd + fzf).
    bind -M insert ctrl-g _devenv_jump
    bind -M default ctrl-g _devenv_jump
end
