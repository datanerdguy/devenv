# Temas trocáveis: Everforest, Rosé Pine, Catppuccin e Dracula (docs/themes.md).
# Os arquivos de cada tema são gerados no build (themes/default.nix). O comando `theme` aponta
# ~/.local/state/devenv/theme/current para o tema escolhido e avisa os apps abertos.
# Lê o tema atual: Ghostty, tmux e Neovim; com o desktop, também niri e Noctalia.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.theme;
  themes = import ../../themes { inherit pkgs lib; };
  themesDir = "${config.xdg.dataHome}/devenv/themes";
  stateDir = "${config.xdg.stateHome}/devenv/theme";

  theme = pkgs.writeShellApplication {
    name = "theme";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gawk
      procps
      gnugrep
      gnused
      fzf
    ];
    text = ''
      # As variáveis DEVENV_* só servem para os testes (tests/desktop-check.nix).
      THEMES=''${DEVENV_THEMES_DIR:-${lib.escapeShellArg themesDir}}
      STATE=''${DEVENV_THEME_STATE:-${lib.escapeShellArg stateDir}}
      DEFAULT_THEME=${lib.escapeShellArg cfg.default}
      DEFAULT_OPACITY=${lib.escapeShellArg (toString cfg.opacity)}
    ''
    + builtins.readFile ./theme.sh;
  };
in
{
  options.devenv.theme = {
    enable = lib.mkEnableOption "temas trocáveis (comando theme)";

    default = lib.mkOption {
      type = lib.types.enum themes.ids;
      default = "everforest";
      description = "Tema usado até você escolher outro com `theme <nome>`.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = theme;
      description = "O comando `theme` (usado pelos testes).";
    };

    themes = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = themes.all;
      description = "Pasta com os arquivos gerados de todos os temas (usada pelos testes).";
    };

    noctaliaPalettes = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = themes.noctaliaPalettes;
      description = "Paletas dos temas no formato do Noctalia (usada pelos testes).";
    };

    opacity = lib.mkOption {
      type = lib.types.numbers.between 0 1;
      default = 0.95;
      example = 1.0;
      description = ''
        Opacidade do fundo do terminal (1 = sólido). Também decide o painel do Noctalia:
        1 sólido, de 0.9 a 0.99 suave, abaixo de 0.9 vidro. `theme opacity <n>` muda na hora.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ theme ];

        # Caminho fixo para os temas: o `current` aponta para cá e segue valendo depois de cada switch.
        xdg.dataFile."devenv/themes".source = themes.all;

        # Gera os arquivos do tema salvo (ou do padrão) e avisa os apps abertos.
        home.activation.devenvTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          run ${lib.getExe theme} apply || warnEcho "theme apply falhou; rode 'theme apply' depois"
        '';
      }

      (lib.mkIf config.devenv.desktop.enable {
        xdg.configFile = {
          "noctalia/palettes".source = themes.noctaliaPalettes;
          # Paleta, papéis de parede e transparência do tema atual (gerado pelo `theme`).
          "noctalia/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${stateDir}/noctalia.toml";
        };
      })
    ]
  );
}
