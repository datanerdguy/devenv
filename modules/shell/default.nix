# Shell interativo: fish + starship. Scripts continuam em bash.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.shell;
in
{
  options.devenv.shell.enable = lib.mkEnableOption "fish + starship";

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
        fish_vi_key_bindings
        # Cursor em bloco em todos os modos do vi (o padrão do fish é uma barra "|" na inserção).
        set -g fish_cursor_default block
        set -g fish_cursor_insert block
        set -g fish_cursor_replace_one block
        set -g fish_cursor_replace block
        set -g fish_cursor_visual block
        # Ctrl-F aceita a sugestão também no modo de inserção do vi.
        bind -M insert \cf accept-autosuggestion
        # Ctrl-K abre um arquivo da pasta no nvim; Ctrl-G entra numa subpasta (veja as funções abaixo).
        bind -M insert \ck fzf-nvim
        bind -M insert \cg fzf-cd
        bind \ck fzf-nvim
        bind \cg fzf-cd
        # Go instalado pela distro em /usr/local/go; só entra no PATH se existir.
        test -d /usr/local/go/bin; and fish_add_path -g -a /usr/local/go/bin
        # cargo e rustup (~/.cargo/bin) vêm depois do Nix no PATH, então não escondem as ferramentas dele.
        test -d ~/.cargo/bin; and fish_add_path -g -a ~/.cargo/bin
      '';
      functions = {
        fzf-nvim = {
          description = "Escolher um arquivo da pasta e abrir no nvim";
          body = ''
            set -l file (fd --type f --hidden --follow --max-depth 1 --exclude .git \
              | fzf --info inline --prompt 'nvim file > ' --query (commandline) \
                --bind 'ctrl-d:preview-down,ctrl-u:preview-up' \
                --preview 'bat --style=numbers --color=always {} | head -500')
            if test -n "$file"
              commandline -r "nvim "(string escape -- $file)
              commandline -f execute
            end
            commandline -f repaint
          '';
        };
        fzf-cd = {
          description = "Escolher uma subpasta e entrar nela";
          body = ''
            set -l dir (fd --type d --hidden --follow --max-depth 1 --exclude .git \
              | fzf --info inline --prompt 'Change dir > ' --query (commandline) \
                --bind 'ctrl-d:preview-down,ctrl-u:preview-up' \
                --preview 'eza -l --no-user --no-time {} | head -50')
            if test -n "$dir"
              commandline -r "cd "(string escape -- $dir)
              commandline -f execute
            end
            commandline -f repaint
          '';
        };
      };
      # Os atalhos de clipboard do macOS que o zsh antigo tinha; no Wayland quem copia é o wl-clipboard.
      shellAliases = {
        pbcopy = "wl-copy";
        pbpaste = "wl-paste";
      };
      shellAbbrs = {
        g = "git";
        gs = "git status -sb";
        lg = "lazygit";
        # Os mesmos nomes do zsh antigo (lsd), agora com o eza.
        # l = permissão e nome; lt = com data; lw = com tamanho; o "a" mostra os ocultos.
        l = "eza -l --no-user --no-time --no-filesize";
        la = "eza -la --no-user --no-time --no-filesize";
        ll = "eza -la --git --group-directories-first";
        lt = "eza -l --no-user --no-filesize";
        lta = "eza -la --no-user --no-filesize";
        lw = "eza -l --no-user --no-time";
        lwa = "eza -la --no-user --no-time";
        tree = "eza --tree --level=2";
        v = "nvim";
        hms = "home-manager switch --flake ~/devenv";
        # Os mais usados do plugin git do oh-my-zsh.
        ga = "git add";
        gaa = "git add --all";
        gb = "git branch";
        gco = "git checkout";
        gcmsg = "git commit -m";
        gd = "git diff";
        gl = "git pull";
        gp = "git push";
        gst = "git status";
      };
    };

    # bash continua como shell de login; ele entrega o terminal para o fish.
    # Assim nada do sistema quebra se o fish faltar.
    programs.bash = {
      enable = true;
      initExtra = ''
        if [[ $- == *i* && -z ''${BASH_EXECUTION_STRING:-} && $(ps -o comm= -p "$PPID") != "fish" ]] \
          && command -v fish >/dev/null; then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec fish $LOGIN_OPTION
        fi
      '';
    };

    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        command_timeout = 500;
        scan_timeout = 200;
        format = "$directory$git_branch$git_status$python$nodejs$golang$rust$elixir$nix_shell$cmd_duration$line_break$character";
        directory.truncation_length = 3;
        cmd_duration.min_time = 2000;
        nix_shell.format = "[$symbol]($style) ";
        python.format = "[$symbol$virtualenv]($style) ";
      };
    };
  };
}
