# Apps do desktop. Os gráficos vêm de fora do Nix, para acharem a GPU sem ajuda:
#   - Flatpak (Flathub), declarados aqui pelo nix-flatpak: navegador, Bitwarden, Obsidian, OBS, Rnote...
#   - distro (system/<distro>.sh): Flameshot, wayscriber, zathura, imv, mpv.
# Aqui ficam a lista de Flatpaks, as configs e os apps padrão por tipo de arquivo.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.apps;
  shots = "${config.home.homeDirectory}/Pictures/Screenshots";

  # Semente da config do Flameshot: copiada só se não existir (o Flameshot grava nela pela tela de ajustes).
  flameshotIni = pkgs.writeText "flameshot.ini" ''
    [General]
    savePath=${shots}
    savePathFixed=true
    useGrimAdapter=true
    disabledGrimWarning=true
    showStartupLaunchMessage=false
    showDesktopNotification=true
    copyPathAfterSave=false
    uiColor=#a7c080
    contrastUiColor=#2d353b
  '';
in
{
  options.devenv.apps = {
    enable = lib.mkEnableOption "apps do desktop (Flatpaks e configs)";

    flatpaks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "app.zen_browser.zen" # navegador (Firefox, com abas verticais e atalhos de teclado)
        "com.bitwarden.desktop"
        "md.obsidian.Obsidian" # notas; o Neovim abre o mesmo cofre (docs/notes.md)
        "com.obsproject.Studio" # gravação e transmissão com cenas
        "com.dec05eba.gpu_screen_recorder" # gravação leve pela GPU, com replay
        "com.github.flxzt.rnote" # desenho à mão (mesa digitalizadora)
      ];
      description = "Apps do Flathub instalados pelo devenv. Definir no host troca a lista inteira.";
    };

    extraFlatpaks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "com.spotify.Client" ];
      description = "Flatpaks a mais, só deste host (somados à lista padrão).";
    };

    browser = lib.mkOption {
      type = lib.types.str;
      default = "app.zen_browser.zen";
      description = "Navegador padrão (id do .desktop, sem a extensão). Super+B abre ele.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Super+B: abre o navegador escolhido (Flatpak ou da distro).
    home.packages = [
      (pkgs.writeShellScriptBin "devenv-browser" ''
        if flatpak info ${cfg.browser} >/dev/null 2>&1; then
          exec flatpak run ${cfg.browser} "$@"
        fi
        exec ${cfg.browser} "$@"
      '')
    ];

    services.flatpak = {
      enable = true;
      packages = cfg.flatpaks ++ cfg.extraFlatpaks;
      # Atualiza os Flatpaks uma vez por semana, sem travar o switch.
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };

    home.activation.devenvFlameshot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e ${config.xdg.configHome}/flameshot/flameshot.ini ]; then
        run mkdir -p ${config.xdg.configHome}/flameshot
        run install -m 0644 ${flameshotIni} ${config.xdg.configHome}/flameshot/flameshot.ini
      fi
    '';

    xdg.configFile."zathura/zathurarc".text = ''
      set selection-clipboard clipboard
      set adjust-open width
      set recolor-keephue true
      map <C-r> recolor
    '';

    # Abrir arquivos e links com os apps certos.
    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        let
          browser = "${cfg.browser}.desktop";
          set = app: types: lib.genAttrs types (_: app);
        in
        set browser [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
        ]
        // set "org.pwmt.zathura.desktop" [ "application/pdf" ]
        // set "imv.desktop" [
          "image/png"
          "image/jpeg"
          "image/gif"
          "image/webp"
          "image/svg+xml"
        ]
        // set "mpv.desktop" [
          "video/mp4"
          "video/webm"
          "video/x-matroska"
          "audio/mpeg"
          "audio/flac"
        ]
        // set "md.obsidian.Obsidian.desktop" [ "x-scheme-handler/obsidian" ];
    };

    # Os .desktop dos Flatpaks do usuário aparecem no launcher.
    xdg.systemDirs.data = [ "${config.xdg.dataHome}/flatpak/exports/share" ];
  };
}
