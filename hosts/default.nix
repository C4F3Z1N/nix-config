{ inputs, lib ? (import <nixpkgs> { }).lib, ... }:
let
  readDir' = path:
    lib.mapAttrs (found: _: path + "/${found}") (builtins.readDir path);

  nixosConfigurations =
    lib.filterAttrs (name: _: name != "default.nix") (readDir' ./.);
  entries = lib.mapAttrs (_: modulePath:
    lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ modulePath ];
    }) nixosConfigurations;
in entries
