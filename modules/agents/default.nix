# Agente de código: Claude Code, com config gerada a partir de agents/ (ADR 0003).
#
# - Instruções: agents/AGENTS.md, importado pelo ~/.claude/CLAUDE.md.
# - Skills: agents/skills (nossas) + as do workmux, em ~/.claude/skills.
# - Configs: o Claude também edita os próprios arquivos (login, confiança em pastas...), então
#   o devenv não os substitui: só mescla as chaves que gerencia, a cada switch (merge-config.py).
# - Sessões paralelas: workmux (worktree + janela do tmux por tarefa).
# - Uso e custo: statusline do Claude, cota na barra do tmux, tokscale para o histórico.
{
  config,
  lib,
  pkgs,
  llmAgents,
  ...
}:
let
  cfg = config.devenv.agents;
  repo = "${cfg.repoPath}/agents";
  link = config.lib.file.mkOutOfStoreSymlink;
  home = config.home.homeDirectory;

  # Índice local de documentação (MCP `docs`). Também serve como CLI: `docs-mcp scrape polars https://docs.pola.rs`
  docsMcp = pkgs.writeShellScriptBin "docs-mcp" ''
    export DOCS_MCP_STORE_PATH="''${DOCS_MCP_STORE_PATH:-${config.xdg.dataHome}/docs-mcp}"
    export DOCS_MCP_TELEMETRY=false
    exec ${pkgs.nodejs_22}/bin/npx -y @arabold/docs-mcp-server@${cfg.docsMcpVersion} "$@"
  '';

  mergeConfig = pkgs.writers.writePython3 "devenv-merge-config" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ../../agents/merge-config.py);

  statusline = pkgs.writeShellApplication {
    name = "devenv-claude-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.git
      pkgs.coreutils
    ];
    text = builtins.readFile ../../agents/statusline.sh;
  };

  # Status dos agentes nas janelas do tmux (🤖 trabalhando, 💬 esperando, ✅ pronto).
  wm = state: {
    type = "command";
    command = "workmux set-window-status ${state}";
  };
  hook = matcher: hooks: [
    ((lib.optionalAttrs (matcher != null) { inherit matcher; }) // { inherit hooks; })
  ];
  register = {
    type = "command";
    command = "workmux register-agent";
  };

  context7Url = "https://mcp.context7.com/mcp";

  # Chaves gerenciadas. Viram JSON e são mescladas no arquivo do Claude.
  managed = {
    "${home}/.claude/settings.json" = {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      env = {
        DISABLE_AUTOUPDATER = "1"; # quem atualiza é o Nix (llm-agents.nix)
      };
      statusLine = {
        type = "command";
        command = lib.getExe statusline;
        padding = 0;
      };
      sandbox = {
        enabled = cfg.sandbox; # bubblewrap + socat (instalados pela distro)
        autoAllowBashIfSandboxed = true;
      };
      model = cfg.claudeModel; # padrão da sessão; `/model` troca na hora
      teammateMode = "auto"; # agent teams em painéis do tmux, quando ligadas (`cteam`)
      hooks = {
        SessionStart = hook "startup|resume|clear|fork" [ register ];
        UserPromptSubmit = hook null [ (wm "working") ];
        Notification = hook "permission_prompt|elicitation_dialog" [ (wm "waiting") ];
        PostToolUse = hook null [ (wm "working") ];
        Stop = hook null [ (wm "done") ];
      };
    };

    # Estado do Claude Code; aqui só os servidores MCP do usuário.
    "${home}/.claude.json".mcpServers = {
      context7 = {
        type = "http";
        url = context7Url;
      };
      docs = {
        type = "stdio";
        command = lib.getExe docsMcp;
        args = [
          "mcp"
          "--protocol"
          "stdio"
        ];
      };
    };
  };

  fragments = lib.mapAttrs (
    path: value: pkgs.writeText "devenv-${baseNameOf path}.json" (builtins.toJSON value)
  ) managed;

  # Skills: as nossas (editáveis no repo) e as do workmux (/merge, /worktree, /coordinator...).
  ourSkills = [
    "route"
    "second-opinion"
    "nvim-lua"
  ];
  workmuxSkills = [
    "workmux"
    "worktree"
    "coordinator"
    "merge"
    "rebase"
    "open-pr"
  ];
  skillFiles = lib.listToAttrs (
    map (s: lib.nameValuePair ".claude/skills/${s}" { source = link "${repo}/skills/${s}"; }) ourSkills
    ++ map (
      s: lib.nameValuePair ".claude/skills/${s}" { source = "${llmAgents.workmux.src}/skills/${s}"; }
    ) workmuxSkills
  );
in
{
  options.devenv.agents = {
    enable = lib.mkEnableOption "Claude Code, workmux e os MCPs de documentação";

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${home}/devenv";
      description = "Onde este repositório está clonado (instruções e skills são lidas de lá).";
    };

    claudeModel = lib.mkOption {
      type = lib.types.str;
      default = "sonnet";
      example = "opusplan";
      description = "Modelo padrão do Claude Code (`sonnet`, `opus`, `opusplan`, `haiku`). Sonnet poupa a cota do Pro; o roteamento por tarefa fica no AGENTS.md.";
    };

    sandbox = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Sandbox nativo do Claude Code nos comandos de shell (bubblewrap).";
    };

    docsMcpVersion = lib.mkOption {
      type = lib.types.str;
      default = "3.3.0";
      description = "Versão do @arabold/docs-mcp-server usada pelo MCP `docs`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      llmAgents.claude-code
      llmAgents.workmux
      llmAgents.tokscale
      docsMcp
    ];

    home.file = {
      ".config/agents/AGENTS.md".source = link "${repo}/AGENTS.md";
      ".claude/CLAUDE.md".text = "@~/.config/agents/AGENTS.md\n";
    }
    // skillFiles;

    home.activation.devenvAgentConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (path: frag: "run ${mergeConfig} ${lib.escapeShellArg path} ${frag}") fragments
      )
    );

    # workmux: o painel grava o tema escolhido (tecla T) na config, então ela é uma cópia editável.
    home.activation.devenvWorkmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run install -D -m 644 ${./workmux.yaml} ${lib.escapeShellArg "${config.xdg.configHome}/workmux/config.yaml"}
    '';

    programs.fish.shellAbbrs = lib.mkIf config.devenv.shell.enable {
      cc = "claude";
      cteam = "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude"; # agent teams só nesta sessão
      wa = "workmux add";
      wd = "workmux dashboard";
      wm = "workmux merge";
      usage = "tokscale --tui";
    };
  };
}
