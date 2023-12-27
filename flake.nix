{
  inputs = {
    nixpkgs.follows = "stable-pkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    sops.url = "github:mic92/sops-nix";
    sops.inputs.nixpkgs.follows = "nixpkgs";
    sops.inputs.nixpkgs-stable.follows = "stable-pkgs";

    wayland-pkgs.url = "github:nix-community/nixpkgs-wayland";
    wayland-pkgs.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stable-pkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable-pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, ... }:
    let
      lib = with inputs; (nixpkgs.lib // flake-parts.lib // home-manager.lib);
      readDir' = path:
        lib.mapAttrs (found: _: path + "/${found}") (builtins.readDir path);
    in lib.mkFlake { inherit inputs; } {
      flake = rec {
        inherit lib;

        nixosConfigurations = lib.mapAttrs (hostName: modulePath:
          lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ modulePath ];
          }) (readDir' ./hosts);

        homeConfigurations = {
          "joao@lelia" = lib.homeManagerConfiguration {
            inherit (nixosConfigurations.lelia) pkgs;
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./common/home/joao ];
          };
        };
      };

      perSystem = { inputs', pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          NIX_CONFIG =
            "extra-experimental-features = flakes nix-command repl-flake";
          packages = with pkgs; [
            (inputs'.disko.packages.disko)
            age
            gitMinimal
            gnupg
            nixos-anywhere
            nixos-install-tools
            pinentry
            sops
            ssh-to-age
          ];
        };

        formatter = pkgs.nixfmt;
      };

      systems = [ "aarch64-linux" "x86_64-linux" ];
    };
}
