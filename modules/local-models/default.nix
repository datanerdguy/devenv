# Modelos locais com Ollama. Desligado por padrão: ligado, instala o Ollama como serviço do
# usuário e registra os modelos no opencode (o agente para modelos locais).
{ config, lib, ... }:
let
  cfg = config.devenv.localModels;
in
{
  options.devenv.localModels = {
    enable = lib.mkEnableOption "modelos locais com Ollama";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Sobe o Ollama no login. Desligado: `systemctl --user start ollama` (abreviação `ollama-on`).";
    };

    acceleration = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          false
          "cuda"
          "rocm"
          "vulkan"
        ]
      );
      default = null;
      example = "cuda";
      description = ''
        Aceleração por GPU (null = só CPU). Fora do NixOS, a GPU precisa do
        `sudo non-nixos-gpu-setup` que o home-manager indica no switch.
      '';
    };

    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "qwen3-coder:30b" ];
      description = "Modelos oferecidos no opencode (baixe com `ollama pull <modelo>`).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      inherit (cfg) acceleration;
    };
    # Sem autoStart, o serviço existe mas não sobe sozinho: nada rodando sem uso.
    systemd.user.services.ollama.Install.WantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce [ ]);

    programs.fish.shellAbbrs = lib.mkIf config.devenv.shell.enable {
      ollama-on = "systemctl --user start ollama";
      ollama-off = "systemctl --user stop ollama";
    };
  };
}
