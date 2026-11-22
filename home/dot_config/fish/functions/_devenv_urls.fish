# P u no tmux: os links do painel (do mais recente ao mais antigo) num fzf; o Enter abre no navegador.
function _devenv_urls --argument-names painel
    set -l links (tmux capture-pane -J -p -S -5000 -t $painel | tac \
        | rg -o 'https?://[^\s<>"\'`)\]]+' | string trim -r -c '.,;:!?' | awk '!visto[$0]++')
    if test (count $links) -eq 0
        tmux display 'nenhum link no painel'
        return
    end
    set -l escolha (printf '%s\n' $links | fzf --height=100% --layout=reverse --border=none --color=16 \
        --prompt '❯ ' --pointer '▌' --gutter ' ' --no-scrollbar --header 'Enter abre no navegador')
    or return
    # setsid: o navegador continua aberto quando o popup fecha.
    setsid -f xdg-open $escolha >/dev/null 2>&1
end
