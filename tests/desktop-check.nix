# Valida as configs do desktop com os próprios programas, sem abrir sessão gráfica:
# niri, sway (backend headless), i3, kanata, o docs/keyboard.md gerado a partir dos .vil
# e os quatro temas (Ghostty, niri e Noctalia com os arquivos que o `theme` gera).
{
  pkgs,
  src,
  kanataConfig,
  theme,
}:
pkgs.runCommand "devenv-desktop-check"
  {
    nativeBuildInputs = with pkgs; [
      niri
      sway-unwrapped # o `sway` do nixpkgs abre um dbus antes, que não existe no build
      i3
      kanata
      python3
      noctalia
      ghostty
      tmux
    ];
  }
  ''
    export HOME="$TMPDIR/home" XDG_RUNTIME_DIR="$TMPDIR/run"
    mkdir -p "$HOME/.config/devenv" "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
    cp ${src}/config/wm/common.conf "$HOME/.config/devenv/wm-common.conf"
    touch "$HOME/.config/devenv/sway-local.conf" "$HOME/.config/devenv/i3-local.conf"

    echo "niri";   niri validate -c ${src}/config/niri/config.kdl
    echo "sway";   WLR_BACKENDS=headless WLR_RENDERER=pixman sway --validate -c ${src}/config/sway/config
    echo "i3";     i3 -C -c ${src}/config/i3/config
    echo "kanata"; kanata --check --cfg ${kanataConfig}
    echo "teclado"; python3 ${src}/keyboard/render.py --check

    # Temas: gera cada um como o `theme <nome>` faria e valida o resultado.
    export DEVENV_THEMES_DIR=${theme.themes} DEVENV_THEME_STATE="$HOME/.local/state/devenv/theme"
    mkdir -p "$HOME/.config/noctalia"
    cp ${src}/config/noctalia/devenv.toml "$HOME/.config/noctalia/"
    ln -s ${theme.noctaliaPalettes} "$HOME/.config/noctalia/palettes"
    ln -s "$DEVENV_THEME_STATE/noctalia.toml" "$HOME/.config/noctalia/theme.toml"
    for id in $(${theme.package}/bin/theme list); do
      echo "tema $id"
      ${theme.package}/bin/theme "$id" >/dev/null
      ghostty +validate-config --config-file="$DEVENV_THEME_STATE/ghostty"
      niri validate -c ${src}/config/niri/config.kdl
      noctalia config validate | grep -v '^WARN' || true
      noctalia config validate >/dev/null
      tmux -L check -f /dev/null new-session -d \; source-file "$DEVENV_THEME_STATE/current/tmux.conf" \; kill-server
      # A paleta tem as 16 cores do terminal e o Noctalia acha ela pelo nome.
      test "$(grep -c '^palette = ' "$DEVENV_THEME_STATE/ghostty")" = 16
      test -f "$HOME/.config/noctalia/palettes/$(cat "$DEVENV_THEME_STATE/current/name").json"
      test -n "$(ls "$DEVENV_THEME_STATE/current/wallpapers")"
    done
    ${theme.package}/bin/theme opacity 0.8 >/dev/null
    grep -q 'transparency_mode = "glass"' "$DEVENV_THEME_STATE/noctalia.toml"

    touch "$out"
  ''
