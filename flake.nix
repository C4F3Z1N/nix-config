{
  inputs = {
    nixpkgs.follows = "stable-pkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "stable-pkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-keys = {
      url = "https://github.com/c4f3z1n.keys";
      flake = false;
    };

    stable-pkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable-pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ devshell, flake-parts, treefmt-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = map (builtins.getAttr "flakeModule") [ devshell treefmt-nix ];

      flake = {
        nixosConfigurations = import ./hosts { inherit inputs; };
        homeConfigurations = import ./common/home { inherit inputs; };
      };

      perSystem = { inputs', pkgs, ... }: {
        devshells.default =
          import ./common/devshell.nix { inherit inputs' pkgs; };

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };
      };

      systems = [ "aarch64-linux" "x86_64-linux" ];
    };
}
