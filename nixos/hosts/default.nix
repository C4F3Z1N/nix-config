{ inputs }:
let inherit (inputs.nixpkgs) lib;
in rec {
  rawContent = lib.pipe ./. [
    (builtins.readDir)
    (lib.filterAttrs (name: _: name != "default.nix"))
    (builtins.mapAttrs (name: _: ./. + "/${name}"))
  ];

  nixosConfigurations = builtins.mapAttrs (_: modulePath:
    lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ modulePath ];
    }) rawContent;
}
