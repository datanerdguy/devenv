# Ferramentas de linha de comando do dia a dia.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.cli;
in
{
  options.devenv.cli.enable = lib.mkEnableOption "ferramentas de CLI";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # busca e navegação
      ripgrep
      fd
      eza
      # dados (fluxos em docs/data.md)
      jq
      yq-go
      duckdb # SQL em CSV/Parquet/JSON e bancos; `duckdb -ui` abre um notebook local
      harlequin # IDE de SQL no terminal: DuckDB, SQLite, Postgres
      tabiew # `tw`: ver CSV, Parquet, Excel e SQLite, com SQL em cima
      pgcli # consulta rápida no Postgres
      litecli # consulta rápida no SQLite
      # sistema e utilidades
      btop
      just
      xh
      tldr
      unzip
      wget
      # segredos: cliente do Bitwarden (`rbw get <nome>`); configure com `rbw config set email ...`
      rbw
      pinentry-curses
    ];

    programs.fzf = {
      enable = true;
      historyWidget.command = ""; # Ctrl-R fica com o atuin
    };
    programs.bat.enable = true;
    programs.zoxide.enable = true;

    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ]; # seta para cima continua normal; Ctrl-R abre o atuin
      settings = {
        style = "compact";
        inline_height = 20;
        enter_accept = false;
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # ativa o devShell do projeto ao entrar na pasta
    };

    programs.yazi = {
      enable = true;
      # Tabelas abrem no tabiew; o editor fica como segunda opção (tecla O).
      settings = {
        opener.tabiew = [
          {
            run = "tw %s1";
            block = true;
            desc = "tabiew";
          }
        ];
        open.prepend_rules = [
          {
            url = "*.{csv,tsv,parquet,xlsx,xls,jsonl,arrow,sqlite,db}";
            use = [
              "tabiew"
              "edit"
            ];
          }
        ];
      };
    };
  };
}
