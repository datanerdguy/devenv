# Neovim. O binário vem do bob (nightly, hoje 0.13); a config é config/nvim deste repo,
# ligada direto em ~/.config/nvim: editar o repo muda o editor na hora, sem switch.
# Plugins ficam com o vim.pack (travados em config/nvim/nvim-pack-lock.json).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devenv.nvim;

  # Python só do molten (notebooks). Os kernels vêm do ambiente de cada projeto (ipykernel).
  moltenPython = pkgs.python3.withPackages (
    ps: with ps; [
      pynvim
      jupyter-client
      nbformat
      pillow
      cairosvg
      pyperclip
    ]
  );
in
{
  options.devenv.nvim = {
    enable = lib.mkEnableOption "Neovim (bob + config do repo)";

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/devenv";
      description = "Onde este repositório está clonado (a config do Neovim é lida de lá).";
    };

    version = lib.mkOption {
      type = lib.types.str;
      default = "nightly";
      example = "stable";
      description = "Versão que o bob instala no primeiro switch (nightly, stable ou v0.12.0).";
    };

    tools.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Instala LSPs, formatadores e linters pelo Nix. Sem isso, use o :Mason.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        bob-nvim
        tree-sitter # compila os parsers do nvim-treesitter (precisa de um cc do sistema)
        imagemagick # imagens do molten (image.nvim)
        uv # marimo (uvx marimo) e debug de Python (dap-python)
      ]
      ++ lib.optionals cfg.tools.enable [
        # LSPs (Rust fica com o rust-analyzer do rustup, para bater com o toolchain)
        lua-language-server
        basedpyright
        ruff
        gopls
        nixd
        marksman
        taplo
        yaml-language-server
        vscode-langservers-extracted # html, css, json
        bash-language-server
        dockerfile-language-server
        tailwindcss-language-server
        typescript-language-server
        # formatadores e linters
        stylua
        gofumpt
        gotools # goimports
        nixfmt
        shfmt
        shellcheck
        hadolint
        actionlint
      ];

    home.sessionPath = [ "${config.xdg.dataHome}/bob/nvim-bin" ];
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
      DEVENV_NVIM_PYTHON = "${moltenPython}/bin/python3";
    };

    # O PATH já vem do home.sessionPath; sem isso o bob edita arquivos do shell sozinho.
    xdg.configFile."bob/config.toml".text = ''
      add_neovim_binary_to_path = false
      enable_nightly_info = true
    '';

    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/config/nvim";

    # Instala o Neovim pelo bob enquanto nenhuma versão estiver em uso. Depois: `just nvim-update`.
    home.activation.bobNeovim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # O bob troca de pasta se vê SUDO_USER (ex.: `sudo -iu`) e usa a do usuário original.
      # Sem essas variáveis e com os caminhos explícitos, ele instala para este usuário.
      bob() {
        env -u SUDO_USER -u SUDO_UID -u SUDO_GID -u SUDO_COMMAND \
          HOME="${config.home.homeDirectory}" \
          XDG_CONFIG_HOME="${config.xdg.configHome}" \
          XDG_DATA_HOME="${config.xdg.dataHome}" \
          XDG_CACHE_HOME="${config.xdg.cacheHome}" \
          ${pkgs.bob-nvim}/bin/bob "$@"
      }
      if ! bob ls 2>/dev/null | grep -q Used; then
        run bob use ${cfg.version} \
          || warnEcho "bob não conseguiu instalar o Neovim ${cfg.version}; rode 'bob use ${cfg.version}' depois"
      fi
    '';
  };
}
