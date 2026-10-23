# Notebook principal (Fedora + monitor ultrawide).
# Cada host diz quem é o usuário e quais módulos liga.
_: {
  home.username = "lucas"; # ajuste para o seu usuário (`whoami`)
  home.homeDirectory = "/home/lucas";

  devenv = {
    cli.enable = true;
    shell.enable = true;
    git = {
      enable = true;
      name = "Lucas";
      email = "you@example.com"; # ajuste
    };
    terminal.enable = true;
    nvim.enable = true;
  };
}
