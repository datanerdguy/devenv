# Agentes de código: Claude Code, Codex, Gemini CLI e opencode, com config gerada a partir de agents/.
#
# - Instruções: agents/AGENTS.md é a fonte única, ligada nos quatro agentes.
# - Skills: agents/skills (nossas) + as do workmux, em ~/.agents/skills e ~/.claude/skills.
# - Configs: o agente também edita os próprios arquivos (login, confiança em pastas...), então
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
    libraries = [ pkgs.python3Packages.tomlkit ];
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

  # Chaves gerenciadas de cada agente. Viram JSON/TOML e são mescladas no arquivo do agente.
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

    "${home}/.codex/config.toml" = {
      sandbox_mode = "workspace-write";
      approval_policy = "on-request";
      check_for_update_on_startup = false;
      analytics.enabled = false;
      features.hooks = true; # hooks.json do workmux
      mcp_servers = {
        context7.url = context7Url;
        docs = {
          command = lib.getExe docsMcp;
          args = [
            "mcp"
            "--protocol"
            "stdio"
          ];
        };
      };
    };

    "${home}/.gemini/settings.json" = {
      context.fileName = [
        "AGENTS.md"
        "GEMINI.md"
      ];
      general.enableAutoUpdate = false;
      privacy.usageStatisticsEnabled = false;
      skills.enabled = true;
      mcpServers = {
        context7.httpUrl = context7Url;
        docs = {
          command = lib.getExe docsMcp;
          args = [
            "mcp"
            "--protocol"
            "stdio"
          ];
        };
      };
      hooks = {
        SessionStart = hook null [ register ];
        BeforeAgent = hook null [ (wm "working") ];
        Notification = hook "ToolPermission" [ (wm "waiting") ];
        AfterTool = hook null [ (wm "working") ];
        AfterAgent = hook null [ (wm "done") ];
        SessionEnd = hook null [ (wm "done") ];
      };
    };

    "${config.xdg.configHome}/opencode/opencode.json" = {
      "$schema" = "https://opencode.ai/config.json";
      autoupdate = false;
      mcp = {
        context7 = {
          type = "remote";
          url = context7Url;
        };
        docs = {
          type = "local";
          command = [
            (lib.getExe docsMcp)
            "mcp"
            "--protocol"
            "stdio"
          ];
        };
      };
    }
    // lib.optionalAttrs config.devenv.localModels.enable {
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options.baseURL = "http://127.0.0.1:11434/v1";
        models = lib.genAttrs config.devenv.localModels.models (m: {
          name = m;
        });
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
  ];
  workmuxSkills = [
    "workmux"
    "worktree"
    "coordinator"
    "merge"
    "rebase"
    "open-pr"
  ];
  skillFiles =
    dir:
    lib.listToAttrs (
      map (s: lib.nameValuePair "${dir}/${s}" { source = link "${repo}/skills/${s}"; }) ourSkills
      ++ map (
        s: lib.nameValuePair "${dir}/${s}" { source = "${llmAgents.workmux.src}/skills/${s}"; }
      ) workmuxSkills
    );
in
{
  options.devenv.agents = {
    enable = lib.mkEnableOption "agentes de código (Claude Code, Codex, Gemini CLI, opencode)";

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
      llmAgents.codex
      llmAgents.gemini-cli
      llmAgents.opencode
      llmAgents.workmux
      llmAgents.tokscale
      docsMcp
    ];

    # Instruções: um arquivo, quatro agentes. O Claude lê CLAUDE.md, que importa o AGENTS.md.
    home.file = {
      ".config/agents/AGENTS.md".source = link "${repo}/AGENTS.md";
      ".claude/CLAUDE.md".text = "@~/.config/agents/AGENTS.md\n";
      ".codex/AGENTS.md".source = link "${repo}/AGENTS.md";
      ".gemini/AGENTS.md".source = link "${repo}/AGENTS.md";
      ".config/opencode/AGENTS.md".source = link "${repo}/AGENTS.md";

      # Status do workmux no Codex e no opencode (no Claude e no Gemini vai nos hooks acima).
      ".codex/hooks.json".source = "${llmAgents.workmux.src}/resources/codex/hooks/workmux-status.json";
      ".config/opencode/plugins/workmux-status.ts".source =
        "${llmAgents.workmux.src}/resources/opencode/plugins/workmux-status.ts"; # opencode 1.x
    }
    # ~/.agents/skills: padrão lido por Codex, Gemini CLI e opencode. O Claude lê ~/.claude/skills.
    // skillFiles ".agents/skills"
    // skillFiles ".claude/skills";

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
