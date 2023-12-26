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

    stable-pkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable-pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {self, ...}: let
    inherit (inputs.nixpkgs) lib;
    readDir' = path:
      lib.mapAttrs (found: _: path + "/${found}") (builtins.readDir path);
  in rec {
    inherit lib;

    nixosConfigurations = lib.mapAttrs (hostName: directory:
      lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [directory];
      }) (readDir' ./hosts);

    formatter = lib.mapAttrs' (_: nixosSystem: let
      inherit (nixosSystem) pkgs;
    in
      lib.nameValuePair pkgs.system pkgs.alejandra)
    nixosConfigurations;
  };
}
