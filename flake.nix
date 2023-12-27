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

    stable-pkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable-pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {self, ...}: let
    lib = with inputs; (nixpkgs.lib // flake-parts.lib);
    readDir' = path:
      lib.mapAttrs (found: _: path + "/${found}") (builtins.readDir path);
  in
    lib.mkFlake {inherit inputs;} {
      flake = {
        inherit lib;

        nixosConfigurations = lib.mapAttrs (hostName: modulePath:
          lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules = [modulePath];
          }) (readDir' ./hosts);
      };

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };

      systems = ["aarch64-linux" "x86_64-linux"];
    };
}
