# Git com delta nos diffs e lazygit como interface.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.git;
in
{
  options.devenv.git = {
    enable = lib.mkEnableOption "git, delta e lazygit";
    name = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          inherit (cfg) name email;
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        rerere.enabled = true;
        diff.algorithm = "histogram";
        merge.conflictStyle = "zdiff3";
        alias = {
          wt = "worktree"; # um worktree por tarefa/agente
          last = "log -1 HEAD --stat";
        };
      };
      ignores = [
        ".direnv/"
        ".envrc.local"
        "result"
        ".DS_Store"
      ];
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = false;
      };
    };

    programs.lazygit.enable = true;
    programs.gh.enable = true;
  };
}
