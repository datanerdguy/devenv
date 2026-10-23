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
        home.packages = with pkgs; [
          wl-clipboard
          playerctl
          vial # configurador do Corne (a regra udev vem do system/<distro>.sh)
        ];

        xdg.configFile = {
          "niri".source = link "config/niri";
          "noctalia".source = link "config/noctalia";
        };

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
        home.packages = with pkgs; [
          i3status-rust
          rofi
          i3lock
          flameshot
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
