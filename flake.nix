{
  inputs = {
    my-flakes.url = "github:c4f3z1n/my-flakes";

    devshell.follows = "my-flakes/devshell";
    disko.follows = "my-flakes/disko";
    flake-parts.follows = "my-flakes/flake-parts";
    hardware.follows = "my-flakes/nixos-hardware";
    home-manager.follows = "my-flakes/home-manager";
    impermanence.follows = "my-flakes/impermanence";
    nixpkgs.follows = "my-flakes/nixpkgs-stable";
    sops-nix.follows = "my-flakes/sops-nix";
    treefmt-nix.follows = "my-flakes/treefmt-nix";

    my-keys = {
      url = "https://github.com/c4f3z1n.keys";
      flake = false;
    };
  };

  outputs = inputs@{ devshell, flake-parts, treefmt-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = map (builtins.getAttr "flakeModule") [ devshell treefmt-nix ];

      flake = {
        url = "github:c4f3z1n/nix-config";
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
        };
      };

      systems = [ "aarch64-linux" "x86_64-linux" ];
    };
}
