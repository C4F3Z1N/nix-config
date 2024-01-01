{ inputs, lib ? (import <nixpkgs> { }).lib, ... }:
let
  readDir' = path:
    lib.mapAttrs (found: _: path + "/${found}") (builtins.readDir path);
in lib.mapAttrs (hostName: modulePath:
  lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ modulePath ];
  }) (readDir' ./.)
