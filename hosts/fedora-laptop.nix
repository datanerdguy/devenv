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
    tmux.enable = true;
    agents.enable = true;
    desktop = {
      enable = true;
      sway.enable = false; # sessão alternativa; veja docs/desktop.md
      i3.enable = false;
    };
    # localModels.enable = true; # Ollama; veja docs/agents.md
  };
}
