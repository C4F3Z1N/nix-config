{
  description = "My NixOS and home-manager configurations";

  inputs = {
    # most flake inputs are indirectly referenced,
    # so they're fetched from the local registry;

    # deduplication;
    disko.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix.inputs.flake-compat.follows = "flake-compat";
    nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # avoid recursive inputs rendering;
    nix-registry.flake = false;
    secrets.flake = false;
  };

  outputs = inputs @ {
    disko,
    flake-compat,
    flake-parts,
    home-manager,
    impermanence,
    nix,
    nixos-hardware,
    nixpkgs,
    sops-nix,
    systems,
    treefmt-nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [treefmt-nix.flakeModule];

      flake = {lib, ...}: {
        homeConfigurations = import ./home-manager {inherit inputs lib;};
        nixosConfigurations = import ./nixos/hosts {inherit inputs lib;};
      };

      perSystem.treefmt.config = {
        # programs.alejandra.enable = true;
        programs.nixfmt.enable = true;
        programs.prettier.enable = true;
        projectRootFile = "flake.nix";
        settings.formatter = {
          prettier.includes = ["*.lock"];
          nixfmt.excludes = ["flake.nix"];
          # TODO: use alejandra for flake.nix;
        };
      };

      systems = import systems;
    };
}
