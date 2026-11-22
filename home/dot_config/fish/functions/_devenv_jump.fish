# Ctrl+G: escolhe uma pasta e entra nela. Primeiro as que você mais usa (zoxide), depois todas as do ~ (fd).
# O que já está digitado vira a busca inicial.
function _devenv_jump
    set -l dir (
        begin
            zoxide query --list 2>/dev/null
            fd --type directory --hidden --absolute-path \
                --exclude .git --exclude node_modules --exclude target --exclude .venv \
                --exclude .cache --exclude .cargo --exclude .rustup --exclude go --exclude .npm \
                --exclude .local/share --exclude .local/state . $HOME 2>/dev/null | string trim --right --chars=/
        end | awk '!seen[$0]++' | fzf --scheme=path --prompt='pasta> ' --query=(commandline --current-token) \
            --preview='eza -1 --group-directories-first --icons=always --color=always {}'
    )
    and cd $dir
    commandline --function repaint
end
