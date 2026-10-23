{
  description = "devenv: ambiente de desenvolvimento reproduzível (Nix + home-manager)";

  # Binários prontos dos agentes (llm-agents.nix). Sem isso, Codex e outros compilam do zero.
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Agentes de código (Claude Code, Codex, Gemini CLI, opencode...) atualizados todo dia.
    # Sem `follows`: usa o nixpkgs deles, para bater com o cache binário da numtide.
    llm-agents.url = "github:numtide/llm-agents.nix";
    # Flatpaks declarados no home-manager (apps grandes do Flathub). Sem nixpkgs próprio.
    nix-flatpak.url = "git+https://github.com/gmodena/nix-flatpak?ref=refs/tags/v0.8.0";
    # Segredos cifrados no repo (secrets/<host>.yaml), abertos no login (modules/secrets).
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      llm-agents,
      nix-flatpak,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Cria uma configuração home-manager a partir de um arquivo em hosts/.
      mkHome =
        hostFile:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs.llmAgents = llm-agents.packages.${system};
          modules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            sops-nix.homeManagerModules.sops
            ./modules
            hostFile
          ];
        };
    in
    {
      homeConfigurations = {
        fedora-laptop = mkHome ./hosts/fedora-laptop.nix;
        ci = mkHome ./hosts/ci.nix; # usado pelos testes em container
      };

      # `nix flake check` também valida as configs do desktop e o mapa do teclado (`just desktop-check`).
      checks.${system}.desktop = import ./tests/desktop-check.nix {
        inherit pkgs;
        src = ./.;
        kanataConfig = self.homeConfigurations.ci.config.xdg.configFile."kanata/kanata.kbd".source;
        theme = self.homeConfigurations.ci.config.devenv.theme;
      };

      # `nix fmt` formata os arquivos .nix do repo.
      formatter.${system} = pkgs.nixfmt-tree;

      packages.${system} = {
        # home-manager na mesma versão do flake.lock: `nix run .#home-manager -- switch --flake .#<host>`
        inherit (home-manager.packages.${system}) home-manager;
        # Cria um projeto a partir dos modelos (templates/): `nix run .#new -- python meu-projeto api`
        new = pkgs.callPackage ./modules/templates/new.nix { };
      };

      # `nix develop` dá as ferramentas para mexer no próprio repo
      # e liga os git hooks (formatação, lint e mensagem de commit).
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          nvd
          nixfmt-tree
          statix
          shellcheck
          actionlint
          stylua
          commitizen
          python3 # keyboard/render.py
          keymap-drawer # imagens das camadas do teclado (just keyboard)
        ];
        shellHook = ''
          git config core.hooksPath .githooks
        '';
      };
    };
}
