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
        # Ctrl-F aceita a sugestão também no modo de inserção do vi.
        bind -M insert \cf accept-autosuggestion
      '';
      shellAbbrs = {
        g = "git";
        gs = "git status -sb";
        lg = "lazygit";
        ll = "eza -la --git --group-directories-first";
        lt = "eza --tree --level=2";
        v = "nvim";
        hms = "home-manager switch --flake ~/devenv";
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
        format = "$directory$git_branch$git_status$python$nodejs$golang$rust$elixir$nix_shell$cmd_duration$line_break$character";
        directory.truncation_length = 3;
        cmd_duration.min_time = 2000;
        nix_shell.format = "[$symbol]($style) ";
        python.format = "[$symbol$virtualenv]($style) ";
      };
    };
  };
}
