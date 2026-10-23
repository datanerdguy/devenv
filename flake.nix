{
  description = "devenv: ambiente de desenvolvimento reproduzível (Nix + home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Cria uma configuração home-manager a partir de um arquivo em hosts/.
      mkHome =
        hostFile:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
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
          commitizen
        ];
        shellHook = ''
          git config core.hooksPath .githooks
        '';
      };
    };
}
