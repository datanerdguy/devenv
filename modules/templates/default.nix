# Modelos de projeto (docs/templates.md): o comando `new` cria um projeto a partir de templates/
# (copier), com flake, direnv, just, lint, testes, CI e hooks prontos.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.templates;
in
{
  options.devenv.templates = {
    enable = lib.mkEnableOption "modelos de projeto (comando new)";

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/devenv";
      description = "Onde este repositório está clonado (o `new` lê os modelos de lá).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.callPackage ./new.nix { inherit (cfg) repoPath; })
      pkgs.copier # `just template-update` nos projetos
    ];
  };
}
