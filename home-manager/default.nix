{ inputs }:
let
  inherit (inputs.self) nixosConfigurations;

  lib = inputs.nixpkgs.lib // inputs.home-manager.lib;

  rawContent = lib.pipe ./. [
    (builtins.readDir)
    (lib.filterAttrs (name: _: name != "default.nix"))
    (lib.mapAttrs (name: _: ./. + "/${name}"))
  ];

  combinations = lib.pipe {
    user = lib.attrNames rawContent;
    host = lib.attrNames nixosConfigurations;
  } [
    # create all possible combinations of user + host;
    (lib.cartesianProductOfSets)
    # convert to named list entries;
    (map ({ user, host }:
      lib.nameValuePair "${user}@${host}" {
        modulePath = rawContent."${user}";
        nixosHost = nixosConfigurations."${host}";
      }))
    # convert list to attrSet;
    (builtins.listToAttrs)
  ];
in {
  inherit rawContent;

  homeConfigurations = lib.mapAttrs (_:
    { modulePath, nixosHost }:
    lib.homeManagerConfiguration {
      inherit (nixosHost) pkgs;
      extraSpecialArgs = {
        inherit inputs;
        osConfig = nixosHost.config;
      };
      modules = [ modulePath ];
    }) combinations;
}
