# O comando `new` (docs/templates.md). Usado pelo módulo e exposto no flake (`nix run .#new`).
{
  lib,
  writeShellApplication,
  copier,
  git,
  jq,
  gnused,
  coreutils,
  repoPath ? null,
}:
writeShellApplication {
  name = "new";
  # O nix vem do sistema (o mesmo que roda o home-manager).
  runtimeInputs = [
    copier
    git
    jq
    gnused
    coreutils
  ];
  text = ''
    DEFAULT_REPO=${if repoPath == null then ''"$HOME/devenv"'' else lib.escapeShellArg repoPath}
  ''
  + builtins.readFile ./new.sh;
}
