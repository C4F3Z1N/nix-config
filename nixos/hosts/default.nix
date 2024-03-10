{ inputs, lib ? inputs.nixpkgs.lib }:
let
  dirContent = path:
    lib.pipe path [
      (builtins.readDir)
      (lib.mapAttrs (name: _: path + "/${name}"))
      (lib.filterAttrs (name: _: name != "default.nix"))
    ];

  nixosConfigurations = dirContent ./.;

  entries = lib.mapAttrs (_: modulePath:
    lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ modulePath ];
    }) nixosConfigurations;
in entries
