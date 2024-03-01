{
  inputs = {
    nixpkgs.follows = "nixpkgs-stable";

    hardware.url = "github:nixos/nixos-hardware";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flake-compat.url = "github:edolstra/flake-compat";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-stable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    my-keys = {
      url = "https://github.com/c4f3z1n.keys";
      flake = false;
    };
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
          programs.prettier.enable = true;
          settings.formatter.prettier.includes = [ "*.lock" ];
        };
      };

      systems = [ "aarch64-linux" "x86_64-linux" ];
    };
}
