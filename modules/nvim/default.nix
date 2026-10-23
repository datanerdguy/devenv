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

    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/config/nvim";

    # Instala o Neovim pelo bob só na primeira vez. Depois: `just nvim-update`.
    home.activation.bobNeovim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -x "${config.xdg.dataHome}/bob/nvim-bin/nvim" ]; then
        run ${pkgs.bob-nvim}/bin/bob use ${cfg.version} \
          || warnEcho "bob não conseguiu instalar o Neovim ${cfg.version}; rode 'bob use ${cfg.version}' depois"
      fi
    '';
  };
}
