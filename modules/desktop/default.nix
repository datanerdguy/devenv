# Desktop: niri + Noctalia (sessão principal), sway e i3 opcionais, kanata no teclado do notebook.
# Compositores, Noctalia e portais vêm da distro (system/<distro>.sh): sessão, PAM, GPU e polkit
# dependem dela. Aqui fica a config, ligada direto ao repo (editar muda na hora, sem switch).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.desktop;
  link = path: config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/${path}";

  # Caps Lock: Esc no toque, Ctrl segurando. Só nos teclados listados (o Corne já faz isso no firmware).
  kanataConfig = pkgs.writeText "kanata.kbd" ''
    (defcfg
      process-unmapped-keys yes
      linux-dev-names-include (${lib.concatMapStringsSep " " (d: ''"${d}"'') cfg.kanata.devices})
    )
    (defsrc caps)
    (defalias escctl (tap-hold ${toString cfg.kanata.tapMs} ${toString cfg.kanata.tapMs} esc lctl))
    (deflayer base @escctl)
  '';

  # Semente do qt6ct (copiada só se não existir; a tela dele grava nela).
  qt6ctConf = pkgs.writeText "qt6ct.conf" ''
    [Appearance]
    color_scheme_path=${config.xdg.configHome}/qt6ct/colors/noctalia.conf
    custom_palette=true
    style=Fusion
  '';
in
{
  options.devenv.desktop = {
    enable = lib.mkEnableOption "desktop (niri + Noctalia)";

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/devenv";
      description = "Onde este repositório está clonado (as configs são lidas de lá).";
    };

    sway.enable = lib.mkEnableOption "sessão sway (instale o sway com DEVENV_SWAY=1 no bootstrap)";
    i3.enable = lib.mkEnableOption "sessão i3 em X11 (instale o i3 com DEVENV_I3=1 no bootstrap)";

    kanata = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Remapeia o Caps Lock do teclado do notebook (Esc no toque, Ctrl segurando).";
      };
      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "AT Translated Set 2 keyboard" ];
        description = "Nomes dos teclados que o kanata controla (`kanata --list` mostra os nomes).";
      };
      tapMs = lib.mkOption {
        type = lib.types.ints.positive;
        default = 200;
        description = "Tempo (ms) que separa toque de segurar.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # sway e i3 leem as cores das bordas (e o i3, as da barra) do tema atual.
        assertions = [
          {
            assertion = (cfg.sway.enable || cfg.i3.enable) -> config.devenv.theme.enable;
            message = "devenv.desktop.sway/i3 precisam de devenv.theme.enable = true (as cores vêm do tema).";
          }
        ];

        # Apps Qt da distro (Flameshot) com as cores do tema: o Noctalia gera a paleta do qt6ct.
        home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";
        home.activation.devenvQt6ct = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -e ${config.xdg.configHome}/qt6ct/qt6ct.conf ]; then
            run mkdir -p ${config.xdg.configHome}/qt6ct
            run install -m 0644 ${qt6ctConf} ${config.xdg.configHome}/qt6ct/qt6ct.conf
          fi
        '';

        home.packages = with pkgs; [
          wl-clipboard
          playerctl
          vial # configurador do Corne (a regra udev vem do system/<distro>.sh)
        ];

        xdg.configFile = {
          "niri".source = link "config/niri";
          # Seletor de arquivos pelo portal do GTK: o do GNOME exige o Nautilus (upload/download no Zen).
          "xdg-desktop-portal/niri-portals.conf".source = link "config/xdg-desktop-portal/niri-portals.conf";
          # Arquivo a arquivo: o tema (modules/theme) põe a paleta e o theme.toml na mesma pasta.
          "noctalia/devenv.toml".source = link "config/noctalia/devenv.toml";
        };

        # Até a fase 4, ~/.config/noctalia era um link para a pasta do repo; agora é uma pasta com um
        # link por arquivo. Tira o link antigo antes, senão o home-manager acha que o devenv.toml é um
        # arquivo de fora no caminho.
        home.activation.devenvNoctaliaDir = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          if [ -L ${config.xdg.configHome}/noctalia ]; then
            run rm ${config.xdg.configHome}/noctalia
          fi
        '';

        # O dunst (pacote da distro, ativado por D-Bus) pega o nome org.freedesktop.Notifications antes
        # do Noctalia e as notificações saem com o visual do i3. Sem o i3, o serviço fica mascarado.
        home.activation.devenvMaskDunst = lib.mkIf (!cfg.i3.enable) (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            unit=${config.xdg.configHome}/systemd/user/dunst.service
            if [ ! -e "$unit" ] || [ "$(readlink "$unit")" = /dev/null ]; then
              run mkdir -p "$(dirname "$unit")"
              run ln -sfn /dev/null "$unit"
            fi
          ''
        );

        # picom e nvidia-settings (pacotes da distro) sobem pelo autostart do XDG e falham no niri, que não
        # tem X: a sessão do usuário fica "degraded". Uma cópia local com Hidden=true desliga cada um.
        home.activation.devenvHideX11Autostart = lib.mkIf (!cfg.i3.enable) (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            for src in /etc/xdg/autostart/picom.desktop /etc/xdg/autostart/nvidia-settings*.desktop; do
              [ -e "$src" ] || continue
              dst=${config.xdg.configHome}/autostart/$(basename "$src")
              if [ ! -e "$dst" ]; then
                run mkdir -p "$(dirname "$dst")"
                run sh -c 'printf "[Desktop Entry]\nType=Application\nHidden=true\n" > "$1"' _ "$dst"
              fi
            done
          ''
        );

        # Pasta das capturas do niri.
        home.file."Pictures/Screenshots/.keep".text = "";
      }

      (lib.mkIf (cfg.sway.enable || cfg.i3.enable) {
        xdg.configFile."devenv/wm-common.conf".source = link "config/wm/common.conf";
      })
      (lib.mkIf cfg.sway.enable {
        xdg.configFile."sway".source = link "config/sway";
        home.packages = with pkgs; [
          grim
          slurp
        ];
        # O include do arquivo local precisa existir.
        home.activation.devenvSwayLocal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run touch ${config.xdg.configHome}/devenv/sway-local.conf
        '';
      })
      (lib.mkIf cfg.i3.enable {
        xdg.configFile."i3".source = link "config/i3";
        # picom, nm-applet e feh vêm da distro (system/<distro>.sh), porque usam a GPU e o GTK de lá.
        xdg.configFile."picom/picom.conf".source = link "config/picom/picom.conf";
        # Histórico de cópias: texto e imagens, 30 itens; senhas do Bitwarden ficam de fora.
        xdg.configFile."greenclip.toml".text = ''
          [greenclip]
            history_file = "${config.xdg.cacheHome}/greenclip.history"
            max_history_length = 30
            max_selection_size_bytes = 0
            trim_space_from_selection = true
            use_primary_selection_as_input = false
            blacklisted_applications = ["Bitwarden", "KeePassXC"]
            enable_image_support = true
            image_cache_directory = "${config.xdg.cacheHome}/greenclip"
            static_history = []
        '';
        home.packages = with pkgs; [
          i3status-rust
          rofi
          i3lock
          flameshot
          dex # autostart do XDG
          xss-lock # bloqueia a tela ao suspender
          xclip # clipboard do Neovim no X11
          haskellPackages.greenclip
        ];
        home.activation.devenvI3Local = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run touch ${config.xdg.configHome}/devenv/i3-local.conf
        '';
      })

      (lib.mkIf cfg.kanata.enable {
        home.packages = [ pkgs.kanata ];
        xdg.configFile."kanata/kanata.kbd".source = kanataConfig;
        # Precisa do grupo `input` e da regra udev do uinput (system/<distro>.sh).
        systemd.user.services.kanata = {
          Unit = {
            Description = "kanata: Caps Lock = Esc/Ctrl no teclado do notebook";
            ConditionPathExists = "/dev/uinput";
          };
          Service = {
            ExecStart = "${lib.getExe pkgs.kanata} --cfg ${config.xdg.configHome}/kanata/kanata.kbd";
            Restart = "on-failure";
            RestartSec = 3;
          };
          Install.WantedBy = [ "default.target" ];
        };
      })
    ]
  );
}
