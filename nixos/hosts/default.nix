{ inputs, lib }:
let
  rawContent = lib.pipe ./. [
    (builtins.readDir)
    (lib.filterAttrs (name: _: name != "default.nix"))
    (builtins.mapAttrs (name: _: ./. + "/${name}"))
  ];
in builtins.mapAttrs (_: modulePath:
  lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ modulePath ];
  }) rawContent
