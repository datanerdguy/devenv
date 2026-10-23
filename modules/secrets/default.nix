# Segredos com sops-nix (docs/secrets.md): secrets/<host>.yaml fica cifrado no repo com uma chave age e é
# aberto no login por um serviço do systemd do usuário, em $XDG_RUNTIME_DIR (RAM). A chave fica no Bitwarden.
# Sem o arquivo do host, o módulo não faz nada além de instalar o comando `secrets`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.secrets;
  keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  enabled = cfg.file != null;
  secretPath = name: config.sops.secrets.${name}.path;
in
{
  options.devenv.secrets = {
    host = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Nome do host: os segredos vêm de secrets/<host>.yaml, se o arquivo existir.";
    };

    file = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default =
        let
          f = ../../secrets + "/${cfg.host}.yaml";
        in
        if cfg.host != null && builtins.pathExists f then f else null;
      defaultText = lib.literalExpression "secrets/<host>.yaml, se existir";
      description = "Arquivo cifrado com os segredos. null = sem segredos.";
    };

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/devenv";
      description = "Onde este repositório está clonado (o comando `secrets` edita os arquivos de lá).";
    };

    git = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Nome e e-mail do git vêm de git/name e git/email no arquivo (e não do host).";
    };

    env = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "HF_TOKEN"
        "CONTEXT7_API_KEY"
      ];
      description = "Variáveis de ambiente que vêm de env/<NOME> no arquivo, lidas pelo fish e pelo bash.";
    };
  };

  config = lib.mkMerge [
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "secrets";
          runtimeInputs = with pkgs; [
            sops
            age
            rbw
            git
            coreutils
            findutils
            gnused
          ];
          # systemctl vem do sistema.
          text = ''
            DEFAULT_REPO=${lib.escapeShellArg cfg.repoPath}
            DEFAULT_HOST=${lib.escapeShellArg (if cfg.host == null then "" else cfg.host)}
          ''
          + builtins.readFile ./secrets.sh;
        })
        pkgs.sops
      ];
    }

    (lib.mkIf enabled {
      sops = {
        age.keyFile = keyFile;
        defaultSopsFile = cfg.file;
        secrets =
          lib.genAttrs (map (n: "env/${n}") cfg.env) (_: { })
          // lib.optionalAttrs cfg.git {
            "git/name" = { };
            "git/email" = { };
          };
        templates = lib.mkIf cfg.git {
          "git-identity".content = ''
            [user]
              name = ${config.sops.placeholder."git/name"}
              email = ${config.sops.placeholder."git/email"}
          '';
        };
      };

      # A identidade vem só do arquivo aberto pelo sops; sem a chave, o git avisa que falta nome e e-mail.
      programs.git = lib.mkIf cfg.git {
        settings.user = lib.mkForce { };
        includes = [ { path = config.sops.templates."git-identity".path; } ];
      };

      # Leitura de arquivo sem processo novo (builtin do fish, $(<) do bash): não pesa na abertura do shell.
      programs.fish.shellInit = lib.concatMapStrings (n: ''
        test -r ${secretPath "env/${n}"}; and set -gx ${n} (string collect < ${secretPath "env/${n}"})
      '') cfg.env;
      programs.bash.initExtra = lib.mkBefore (
        lib.concatMapStrings (n: ''
          [ -r ${secretPath "env/${n}"} ] && export ${n}="$(<${secretPath "env/${n}"})"
        '') cfg.env
      );

      # O sops-nix reinicia o serviço a cada `just switch`; sem a chave (máquina nova), isso falharia a troca
      # inteira. Aqui só avisa, e o `secrets restore` abre os segredos depois.
      home.activation.sops-nix = lib.mkForce (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          status=$(${config.systemd.user.systemctlPath} --user is-system-running 2>&1 || true)
          if [ ! -f ${lib.escapeShellArg keyFile} ]; then
            warnEcho "Sem a chave dos segredos (${keyFile}). Rode: secrets restore"
          elif [[ $status == running || $status == degraded ]]; then
            run ${config.systemd.user.systemctlPath} --user restart sops-nix \
              || warnEcho "Os segredos não abriram: veja journalctl --user -u sops-nix"
          fi
          unset status
        ''
      );
    })
  ];
}
