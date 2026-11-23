# P u no tmux: os links do painel (do mais recente ao mais antigo) num fzf; o Enter abre no navegador.
function _devenv_urls --argument-names pane
    set -l urls (tmux capture-pane -J -p -S -5000 -t $pane | tac \
        | rg -o 'https?://[^\s<>"\'`)\]]+' | string trim -r -c '.,;:!?' | awk '!seen[$0]++')
    if test (count $urls) -eq 0
        tmux display 'nenhum link no painel'
        return
    end
    set -l choice (printf '%s\n' $urls | fzf --height=100% --border=none --prompt='link ❯ ' \
        --header='Enter abre no navegador')
    or return
    # setsid: o navegador continua aberto quando o popup fecha.
    setsid -f xdg-open $choice >/dev/null 2>&1
end
