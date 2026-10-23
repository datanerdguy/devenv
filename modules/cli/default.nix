# Ferramentas de linha de comando do dia a dia.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.cli;
in
{
  options.devenv.cli.enable = lib.mkEnableOption "ferramentas de CLI";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # busca e navegação
      ripgrep
      fd
      eza
      # dados
      jq
      yq-go
      duckdb
      visidata
      # sistema e utilidades
      btop
      just
      xh
      tldr
      unzip
      wget
      # segredos: cliente do Bitwarden (`rbw get <nome>`); configure com `rbw config set email ...`
      rbw
      pinentry-curses
    ];

    programs.fzf = {
      enable = true;
      historyWidget.command = ""; # Ctrl-R fica com o atuin
    };
    programs.bat.enable = true;
    programs.zoxide.enable = true;

    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ]; # seta para cima continua normal; Ctrl-R abre o atuin
      settings = {
        style = "compact";
        inline_height = 20;
        enter_accept = false;
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # ativa o devShell do projeto ao entrar na pasta
    };

    programs.yazi.enable = true;
  };
}
