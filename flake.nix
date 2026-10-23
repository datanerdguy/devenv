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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      llm-agents,
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

      # `nix fmt` formata os arquivos .nix do repo.
      formatter.${system} = pkgs.nixfmt-tree;

      # home-manager na mesma versão do flake.lock: `nix run .#home-manager -- switch --flake .#<host>`
      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;

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
        ];
        shellHook = ''
          git config core.hooksPath .githooks
        '';
      };
    };
}
