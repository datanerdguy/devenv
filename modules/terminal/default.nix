# Ghostty. O binário vem da distro (melhor integração com a GPU fora do NixOS);
# o home-manager cuida só da configuração.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.terminal;
in
{
  options.devenv.terminal.enable = lib.mkEnableOption "configuração do Ghostty";

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = null; # instalado por system/<distro>.sh
      enableFishIntegration = true;
      systemd.enable = false; # sem o binário do Nix, não há serviço para gerenciar
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
        window-padding-x = 8;
        window-padding-y = 6;
        window-decoration = false; # o compositor (niri) cuida das janelas
        background-opacity = 0.95; # vai virar valor do tema na fase 5
        cursor-style = "block";
        shell-integration-features = "no-cursor,sudo,title";
        copy-on-select = "clipboard";
        confirm-close-surface = false;
        theme = "Everforest Dark Hard"; # provisório até o sistema de temas
      };
    };

    fonts.fontconfig.enable = true;
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  };
}
