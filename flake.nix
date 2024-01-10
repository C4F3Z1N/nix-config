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

    wayland-pkgs = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = inputs@{ self, ... }:
    let lib = with inputs; (nixpkgs.lib // flake-parts.lib);
    in lib.mkFlake { inherit inputs; } {
      imports = with inputs; [ devshell.flakeModule treefmt-nix.flakeModule ];

      flake = {
        inherit lib;

        nixosConfigurations = import ./hosts { inherit inputs lib; };
        homeConfigurations = import ./common/home { inherit inputs lib; };
      };

      perSystem = { inputs', pkgs, ... }: {
        devshells.default = {
          env = [
            {
              name = "NIX_CONFIG";
              value =
                "extra-experimental-features = flakes nix-command repl-flake";
            }
            {
              name = "NIX_PATH";
              value = "nixpkgs=${inputs.nixpkgs}";
            }
            {
              name = "NIXPKGS_ALLOW_UNFREE";
              value = "1";
            }
          ];

          commands = [{
            help = "update flake lock file";
            name = "update";
            command = "nix flake update";
          }];

          packages = with pkgs; [
            (inputs'.disko.packages.disko)
            (inputs'.home-manager.packages.home-manager)
            age
            gitMinimal
            gnupg
            nixos-anywhere
            nixos-install-tools
            pinentry
            sops
            ssh-to-age
            ssh-to-pgp
            util-linux
          ];
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };
      };

      systems = [ "aarch64-linux" "x86_64-linux" ];
    };
}
