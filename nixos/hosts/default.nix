{ inputs }:
let inherit (inputs.nixpkgs) lib;
in rec {
  rawContent = lib.pipe ./. [
    (builtins.readDir)
    (lib.filterAttrs (name: _: name != "default.nix"))
    (lib.mapAttrs (name: _: ./. + "/${name}"))
  ];

  nixosConfigurations = lib.mapAttrs (_: modulePath:
    lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ modulePath ];
    }) rawContent;
}
