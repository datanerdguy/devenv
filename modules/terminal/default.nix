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
  options.devenv.terminal = {
    enable = lib.mkEnableOption "configuração do Ghostty";
    fontSize = lib.mkOption {
      type = lib.types.numbers.positive;
      default = 12;
      example = 14;
      description = "Tamanho da fonte do Ghostty, em pontos. Ajuste por máquina no host (depende da tela e da escala).";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = null; # instalado por system/<distro>.sh
      enableFishIntegration = true;
      systemd.enable = false; # sem o binário do Nix, não há serviço para gerenciar
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = cfg.fontSize;
        window-padding-x = 8;
        window-padding-y = 6;
        window-decoration = false; # o compositor (niri) cuida das janelas
        cursor-style = "block";
        shell-integration-features = "no-cursor,sudo,title";
        copy-on-select = "clipboard";
        confirm-close-surface = false;
        # Rolar fora do tmux e trocar de aba do Ghostty (dentro do tmux, quem cuida é ele).
        keybind = [
          "alt+shift+k=scroll_page_up"
          "alt+shift+j=scroll_page_down"
          "alt+ctrl+h=previous_tab"
          "alt+ctrl+l=next_tab"
        ];
      }
      # Cores e opacidade vêm do tema atual (comando `theme`); sem o módulo de temas, um tema fixo.
      // (
        if config.devenv.theme.enable then
          { config-file = "?${config.xdg.stateHome}/devenv/theme/ghostty"; }
        else
          {
            theme = "Everforest Dark Hard";
            background-opacity = 0.95;
          }
      );
    };

    fonts.fontconfig.enable = true;
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  };
}
