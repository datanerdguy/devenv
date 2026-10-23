# Valida as configs do desktop com os próprios programas, sem abrir sessão gráfica:
# niri, sway (backend headless), i3, kanata e o docs/keyboard.md gerado a partir dos .vil.
{
  pkgs,
  src,
  kanataConfig,
}:
pkgs.runCommand "devenv-desktop-check"
  {
    nativeBuildInputs = with pkgs; [
      niri
      sway-unwrapped # o `sway` do nixpkgs abre um dbus antes, que não existe no build
      i3
      kanata
      python3
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

    touch "$out"
  ''
