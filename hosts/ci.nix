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
  # Segredos de teste: chave e arquivo falsos em tests/secrets (o smoke.sh confere que abrem).
  devenv.secrets = {
    host = lib.mkForce null;
    file = lib.mkForce ../tests/secrets/ci.yaml;
    env = lib.mkForce [ "DEVENV_TEST_TOKEN" ];
  };
}
