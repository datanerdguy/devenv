# Notebook principal (Fedora i3 Spin + monitor ultrawide).
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
      email = "you@example.com"; # vale até existir secrets/fedora-laptop.yaml (docs/secrets.md)
    };
    terminal = {
      enable = true;
      # fontSize = 14; # padrão 12; no kitty você usava 17 (o tamanho real depende da escala da tela)
    };
    nvim.enable = true;
    tmux.enable = true;
    agents.enable = true;
    desktop = {
      enable = true;
      sway.enable = false; # sessão alternativa; veja docs/desktop.md
      i3.enable = false; # o i3 Spin já tem o seu ~/.config/i3; ligar troca pela config do repo
    };
    apps.enable = true;
    theme.enable = true; # `theme <nome>` troca o tema; veja docs/themes.md
    templates.enable = true; # `new python meu-projeto api`; veja docs/templates.md
    # Segredos de secrets/fedora-laptop.yaml (crie com `secrets init`); veja docs/secrets.md.
    secrets = {
      host = "fedora-laptop";
      # env = [ "HF_TOKEN" ]; # variáveis que vêm de env/<NOME> no arquivo
    };
    # localModels.enable = true; # Ollama; veja docs/agents.md
  };
}
