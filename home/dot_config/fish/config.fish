# Fish. Rápido: a saída do `zoxide init` e do `fzf --fish` vem de um cache gerado uma vez por versão do programa,
# e as funções ficam em functions/, carregadas só no primeiro uso.

# Raiz do repo devenv: este arquivo é um link para home/dot_config/fish/config.fish dentro dele.
set -gx DEVENV (path resolve (status filename) | path dirname | path dirname | path dirname | path dirname)

# mise pelos shims, não pelo `mise activate`: o activate roda o mise a cada prompt (uns 15 ms); o shim só
# quando o programa roda. A versão continua sendo a do projeto. O que fica de fora é o [env] do mise.toml.
fish_add_path -g ~/.local/bin ~/.cargo/bin ~/go/bin ~/.local/share/bob/nvim-bin ~/.local/share/mise/shims

set -gx EDITOR nvim
set -gx VISUAL nvim
# bat segue as cores do terminal, então troca junto com o tema.
set -gx BAT_THEME ansi
# O man abre no Neovim: / busca, gO mostra as seções, K abre o manual citado, Ctrl+O volta.
set -gx MANPAGER 'nvim +Man!'
# lazygit lê também as cores do tema, geradas pelo Noctalia.
set -gx LG_CONFIG_FILE $HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/themes/noctalia.yml
set -gx FZF_DEFAULT_COMMAND 'fd --type file --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
# Visual de toda lista do fzf. --color=16: as cores do terminal, que seguem o tema.
set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --border --color=16 --pointer=▌ --gutter=' ' --no-scrollbar --info=inline-right"

status is-interactive; or return

set -g fish_greeting

# Gera "<comando> init" em ~/.cache/fish uma vez, e de novo só quando o programa for atualizado.
function _devenv_source_cached
    set -l bin (command -s $argv[1]); or return
    set -l file $__fish_cache_dir/devenv-$argv[1].fish
    if not test -s $file; or test $bin -nt $file
        mkdir -p $__fish_cache_dir
        $argv >$file
    end
    source $file
end

_devenv_source_cached zoxide init fish

# Vi mode com o cursor sempre em bloco. A cor muda com o modo (o tema define; o padrão é o Nord).
set -g fish_key_bindings fish_vi_key_bindings
set -g fish_cursor_default block
set -g fish_cursor_insert block
set -g fish_cursor_replace_one block
set -g fish_cursor_replace block
set -g fish_cursor_visual block
set -q devenv_cursor_insert; or set -g devenv_cursor_insert A3BE8C
set -q devenv_cursor_normal; or set -g devenv_cursor_normal BF616A
set -q devenv_cursor_visual; or set -g devenv_cursor_visual EBCB8B

function _devenv_cursor_color --on-variable fish_bind_mode --on-event fish_postexec
    switch $fish_bind_mode
        case insert
            printf '\e]12;#%s\a' $devenv_cursor_insert
        case visual
            printf '\e]12;#%s\a' $devenv_cursor_visual
        case '*'
            printf '\e]12;#%s\a' $devenv_cursor_normal
    end
end

# O programa que vai rodar (nvim, lazygit...) começa com a cor de cursor padrão do terminal.
function _devenv_cursor_reset --on-event fish_preexec
    printf '\e]112\a'
end

# Abreviações: viram o comando inteiro ao apertar espaço, então o histórico guarda o comando de verdade.
abbr -a g git
abbr -a gs git status -sb
abbr -a ga git add
abbr -a gc git commit
abbr -a gca git commit --amend
abbr -a gp git push
abbr -a gl git pull
abbr -a gd git diff
abbr -a gds git diff --staged
abbr -a gsw git switch
abbr -a glg git log --oneline --graph -20
abbr -a lg lazygit
abbr -a v nvim
abbr -a j just
abbr -a dv just --justfile '$DEVENV/justfile'
# .. sobe uma pasta, ... sobe duas, e assim por diante.
abbr -a dotdot --regex '^\.\.+$' --function _devenv_multicd
# !! vira o último comando (ex.: sudo !!).
abbr -a !! --position anywhere --function _devenv_last_command
