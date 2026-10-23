# Ponto de entrada dos módulos. Cada pasta é um módulo com `devenv.<nome>.enable`.
_: {
  imports = [
    ./cli
    ./shell
    ./git
    ./terminal
    ./nvim
  ];

  # Fora do NixOS (Fedora, Ubuntu, Arch): ajusta variáveis e caminhos de sistema.
  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;
  xdg.enable = true;

  # Versão do formato de estado do home-manager. Não mude depois de instalado.
  home.stateVersion = "26.05";
}
