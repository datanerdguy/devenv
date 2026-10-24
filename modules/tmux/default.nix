# tmux escrito do zero, sem plugins (leve), + sesh para sessões por projeto.
# Prefixo: Ctrl-Space. Navegação Ctrl-h/j/k/l compartilhada com o Neovim (smart-splits).
{ config, lib, ... }:
let
  cfg = config.devenv.tmux;
in
{
  options.devenv.tmux.enable = lib.mkEnableOption "tmux + sesh";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      prefix = "C-Space";
      baseIndex = 1;
      escapeTime = 10; # Esc rápido no Neovim
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      focusEvents = true; # o Neovim recarrega arquivos ao voltar o foco
      terminal = "tmux-256color";
      # Painéis novos abrem o fish do home-manager, mesmo com login em zsh ou bash.
      shell = lib.mkIf config.devenv.shell.enable "${config.programs.fish.package}/bin/fish";
      sensibleOnTop = false;
      extraConfig = builtins.readFile ./tmux.conf;
    };

    # Sessões por projeto: prefixo + s abre a lista (projetos do zoxide, sessões abertas, configs).
    programs.sesh = {
      enable = true;
      tmuxKey = "s";
      settings = {
        default_session.preview_command = "eza --all --git --icons --color=always {}";
        session = [
          {
            name = "devenv";
            path = "~/devenv";
            startup_command = "nvim";
          }
        ];
      };
    };
    programs.fzf.tmux.enableShellIntegration = true;
  };
}
