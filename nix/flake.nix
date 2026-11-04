{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-macos-vm.url = "git+https://github.com/ustr/nixos-macos-vm";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs-unstable, nixos-macos-vm, nix-darwin, nix-homebrew, home-manager, ... }:
  let
    pkgs-unstable = import nixpkgs-unstable {
      system = "aarch64-darwin";
      config.allowUnfreePredicate = pkg: nixpkgs-unstable.lib.getName pkg == "claude-code";
    };
  in {
    nixosConfigurations.laptop-vm = nixos-macos-vm.nixosConfigurations.default;

    darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self pkgs-unstable; };

      modules = [
        ./darwin
        nixos-macos-vm.darwinModules.default
        { programs.nixos-macos-vm.enable = true; }

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "user";
          };
        }

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.user = import ./home;
        }
      ];
    };
  };
}
