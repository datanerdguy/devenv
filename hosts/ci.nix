# Host usado só pelo CI: a mesma configuração do notebook, com um usuário de teste.
{ lib, ... }:
{
  imports = [ ./fedora-laptop.nix ];

  home.username = lib.mkForce "dev";
  home.homeDirectory = lib.mkForce "/home/dev";
  devenv.git.email = lib.mkForce "ci@example.com";
  # Liga as sessões opcionais para os testes cobrirem as configs delas.
  devenv.desktop.sway.enable = lib.mkForce true;
  devenv.desktop.i3.enable = lib.mkForce true;
}
