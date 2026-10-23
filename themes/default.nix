# Temas do devenv. Cada pasta tem a paleta (palette.json, no formato de paleta do Noctalia,
# com as 16 cores do terminal). Daqui saem os arquivos de cada app, gerados no build:
#   ghostty, tmux.conf, niri.kdl, btop, zathura, sway/i3, Obsidian, Flameshot, os papéis de parede
#   e a própria paleta para o Noctalia.
# O comando `theme` (modules/theme) só aponta para a pasta do tema escolhido e avisa os apps.
{ pkgs, lib }:
let
  # Papéis de parede: baixados das coleções de cada tema, com hash fixo. O primeiro é o padrão.
  gh =
    repo: rev: path:
    "https://raw.githubusercontent.com/${repo}/${rev}/${path}";
  everforestWalls = gh "Apeiros-46B/everforest-walls" "8f538b4e34a880748a471dc4c7aade6e29982417";
  rosePineWalls = gh "rose-pine/wallpapers" "ee39a37b24ab7700cc4d52f50b01a5d13df6a865";
  catppuccinWalls = gh "zhichaoh/catppuccin-wallpapers" "1023077979591cdeca76aae94e0359da1707a60e";
  draculaWalls = gh "dracula/wallpaper" "f2b8cc4223bcc2dfd5f165ab80f701bbb84e3303";

  meta = {
    everforest = {
      name = "Everforest";
      wallpapers = [
        {
          url = everforestWalls "nature/fog_forest_1.png";
          hash = "sha256-wQxWI0FNc37mvRO4zV123NXG50XOO6qKv7J8IKIxgmo=";
        }
        {
          url = everforestWalls "nature/polyscape_1.png";
          hash = "sha256-VxLvKM1oPI0hwquKUvwC6ODuDWCrMMi7Okd0vzUrGto=";
        }
      ];
    };
    rose-pine = {
      name = "Rose Pine";
      wallpapers = [
        {
          url = rosePineWalls "illustration/leafy.png";
          hash = "sha256-/abJuAweceUFRRxe+V/uP00shgYrDOAS/vSzSS5OoDU=";
        }
        {
          url = rosePineWalls "generative/noise-line.png";
          hash = "sha256-/B4IVx5L+9YHwFr6wPznvCpc0T90tG4ocK5o0jnvU6o=";
        }
      ];
    };
    catppuccin = {
      name = "Catppuccin Mocha";
      wallpapers = [
        {
          url = catppuccinWalls "landscapes/shaded_landscape.png";
          hash = "sha256-EZmkN1HxI00/uS7PYU+/NN4sBzNNP901WJEET1G92to=";
        }
        {
          url = catppuccinWalls "landscapes/evening-sky.png";
          hash = "sha256-ZYA0yj704yzbNy+o2Kf+XZliKd4uzUbScW0pMw4/aE0=";
        }
      ];
    };
    dracula = {
      name = "Dracula";
      wallpapers = [
        {
          url = draculaWalls "first-collection/fedora.png";
          hash = "sha256-7GhQueDzewzMneXpn+ao9QPv9zpCvZmkxYKb3asF3Pg=";
        }
        {
          url = draculaWalls "first-collection/base.png";
          hash = "sha256-JXBm6dM9kXpjauvqlax3pPFi4UKCLTEYMPKglOJJehs=";
        }
      ];
    };
  };

  mkTheme =
    id: m:
    let
      palette = lib.importJSON ./${id}/palette.json;
      c = palette.dark; # cores da interface (mPrimary, mSurface...)
      t = c.terminal;
      ansi = [
        "black"
        "red"
        "green"
        "yellow"
        "blue"
        "magenta"
        "cyan"
        "white"
      ];
      colors16 = map (n: t.normal.${n}) ansi ++ map (n: t.bright.${n}) ansi;

      ghostty = pkgs.writeText "ghostty" (
        lib.concatImapStrings (i: col: "palette = ${toString (i - 1)}=${col}\n") colors16
        + ''
          background = ${t.background}
          foreground = ${t.foreground}
          cursor-color = ${t.cursor}
          cursor-text = ${t.cursorText}
          selection-background = ${t.selectionBg}
          selection-foreground = ${t.selectionFg}
        ''
      );

      tmux = pkgs.writeText "tmux.conf" ''
        set -g status-style "bg=${c.mSurface},fg=${c.mOnSurface}"
        set -g status-left "#[fg=${c.mOnPrimary},bg=${c.mPrimary},bold] #S #[bg=${c.mSurface}] "
        set -g status-right "#[fg=${c.mOnSurfaceVariant}]#(cat ~/.cache/devenv/claude-usage 2>/dev/null) #[fg=${c.mOnSurface}]%H:%M "
        setw -g window-status-format " #I #W "
        setw -g window-status-current-format "#[fg=${c.mOnSecondary},bg=${c.mSecondary},bold] #I #W "
        set -g pane-border-style "fg=${c.mOutline}"
        set -g pane-active-border-style "fg=${c.mPrimary}"
        set -g message-style "bg=${c.mSurfaceVariant},fg=${c.mOnSurface}"
        set -g mode-style "bg=${c.mSurfaceVariant}"
        set -g popup-border-style "fg=${c.mOutline}"
      '';

      niri = pkgs.writeText "niri.kdl" ''
        layout {
            focus-ring {
                active-color "${c.mPrimary}"
                inactive-color "${c.mOutline}"
            }
            insert-hint {
                color "${c.mPrimary}80"
            }
        }
      '';

      btop = pkgs.writeText "btop.theme" (
        let
          grad = name: ''
            theme[${name}_start]="${c.mPrimary}"
            theme[${name}_mid]="${c.mSecondary}"
            theme[${name}_end]="${c.mTertiary}"
          '';
        in
        ''
          theme[main_bg]="${c.mSurface}"
          theme[main_fg]="${c.mOnSurface}"
          theme[title]="${c.mPrimary}"
          theme[hi_fg]="${c.mTertiary}"
          theme[selected_bg]="${c.mSurfaceVariant}"
          theme[selected_fg]="${c.mOnSurface}"
          theme[inactive_fg]="${c.mOnSurfaceVariant}"
          theme[graph_text]="${c.mOnSurfaceVariant}"
          theme[meter_bg]="${c.mSurfaceVariant}"
          theme[proc_misc]="${c.mSecondary}"
          theme[cpu_box]="${c.mOutline}"
          theme[mem_box]="${c.mOutline}"
          theme[net_box]="${c.mOutline}"
          theme[proc_box]="${c.mOutline}"
          theme[div_line]="${c.mOutline}"
        ''
        + lib.concatMapStrings grad [
          "temp"
          "cpu"
          "free"
          "cached"
          "available"
          "used"
          "download"
          "upload"
          "process"
        ]
      );

      zathura = pkgs.writeText "zathurarc" ''
        set default-bg "${c.mSurface}"
        set default-fg "${c.mOnSurface}"
        set statusbar-bg "${c.mSurfaceVariant}"
        set statusbar-fg "${c.mOnSurface}"
        set inputbar-bg "${c.mSurface}"
        set inputbar-fg "${c.mOnSurface}"
        set notification-bg "${c.mSurface}"
        set notification-fg "${c.mOnSurface}"
        set notification-error-bg "${c.mError}"
        set notification-error-fg "${c.mOnError}"
        set highlight-color "${c.mPrimary}80"
        set highlight-active-color "${c.mSecondary}80"
        set completion-bg "${c.mSurfaceVariant}"
        set completion-fg "${c.mOnSurface}"
        set completion-highlight-bg "${c.mPrimary}"
        set completion-highlight-fg "${c.mOnPrimary}"
        set index-bg "${c.mSurface}"
        set index-fg "${c.mOnSurface}"
        set index-active-bg "${c.mPrimary}"
        set index-active-fg "${c.mOnPrimary}"
        set recolor-lightcolor "${c.mSurface}"
        set recolor-darkcolor "${c.mOnSurface}"
      '';

      # sway e i3: bordas das janelas; as variáveis $theme_* servem para a barra do i3.
      wm = pkgs.writeText "wm-colors.conf" ''
        set $theme_bg ${c.mSurface}
        set $theme_fg ${c.mOnSurface}
        set $theme_accent ${c.mPrimary}
        set $theme_on_accent ${c.mOnPrimary}
        set $theme_muted ${c.mOutline}
        client.focused          ${c.mPrimary} ${c.mPrimary} ${c.mOnPrimary} ${c.mPrimary} ${c.mPrimary}
        client.focused_inactive ${c.mOutline} ${c.mSurfaceVariant} ${c.mOnSurface} ${c.mOutline} ${c.mOutline}
        client.unfocused        ${c.mOutline} ${c.mSurface} ${c.mOnSurfaceVariant} ${c.mOutline} ${c.mOutline}
        client.urgent           ${c.mError} ${c.mError} ${c.mOnError} ${c.mError} ${c.mError}
      '';

      # Obsidian: snippet de CSS (ligue uma vez em Ajustes > Aparência > Trechos de CSS).
      obsidian = pkgs.writeText "devenv-theme.css" ''
        /* Gerado pelo devenv (comando theme): ${m.name}. */
        .theme-dark {
          --background-primary: ${c.mSurface};
          --background-primary-alt: ${c.mSurfaceVariant};
          --background-secondary: ${c.mShadow};
          --background-secondary-alt: ${c.mSurfaceVariant};
          --background-modifier-border: ${c.mOutline};
          --background-modifier-hover: ${c.mSurfaceVariant};
          --text-normal: ${c.mOnSurface};
          --text-muted: ${c.mOnSurfaceVariant};
          --text-faint: ${c.mOutline};
          --text-accent: ${c.mPrimary};
          --text-accent-hover: ${c.mSecondary};
          --text-on-accent: ${c.mOnPrimary};
          --text-error: ${c.mError};
          --interactive-accent: ${c.mPrimary};
          --interactive-accent-hover: ${c.mSecondary};
          --color-accent: ${c.mPrimary};
          --link-color: ${c.mSecondary};
          --link-external-color: ${c.mTertiary};
          --tag-color: ${c.mTertiary};
          --h1-color: ${c.mPrimary};
          --h2-color: ${c.mSecondary};
          --h3-color: ${c.mTertiary};
        }
      '';

      wallpapers = lib.imap1 (
        i: w:
        pkgs.fetchurl {
          inherit (w) url hash;
          name = "${id}-${toString i}-${baseNameOf w.url}";
        }
      ) m.wallpapers;
    in
    pkgs.runCommand "devenv-theme-${id}" { } ''
      mkdir -p $out/wallpapers
      echo ${lib.escapeShellArg id} > $out/id
      echo ${lib.escapeShellArg m.name} > $out/name
      cp ${./${id}/palette.json} $out/palette.json
      cp ${ghostty} $out/ghostty
      cp ${tmux} $out/tmux.conf
      cp ${niri} $out/niri.kdl
      cp ${btop} $out/btop.theme
      cp ${zathura} $out/zathurarc
      cp ${wm} $out/wm-colors.conf
      cp ${obsidian} $out/obsidian.css
      echo "uiColor=${c.mPrimary}" > $out/flameshot
      echo "contrastUiColor=${c.mSurface}" >> $out/flameshot
      ${lib.concatMapStrings (w: ''
        ln -s ${w} $out/wallpapers/${w.name}
      '') wallpapers}
    '';
in
{
  ids = builtins.attrNames meta;
  inherit meta;
  # Uma pasta com todos os temas: <id>/{id,name,palette.json,ghostty,tmux.conf,niri.kdl,...,wallpapers/}
  all = pkgs.linkFarm "devenv-themes" (lib.mapAttrs mkTheme meta);
  # As paletas com o nome que aparece no Noctalia (~/.config/noctalia/palettes/<Nome>.json).
  noctaliaPalettes = pkgs.linkFarm "devenv-noctalia-palettes" (
    lib.mapAttrs' (id: m: lib.nameValuePair "${m.name}.json" ./${id}/palette.json) meta
  );
}
