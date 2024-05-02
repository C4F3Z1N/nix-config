{ inputs }:
let
  inherit (inputs.self) nixosConfigurations;

  lib = with inputs; nixpkgs.lib // home-manager.lib;

  rawContent = lib.pipe ./. [
    (builtins.readDir)
    (lib.filterAttrs (name: _: name != "default.nix"))
    (builtins.mapAttrs (name: _: ./. + "/${name}"))
  ];

  combinations = lib.pipe {
    user = builtins.attrNames rawContent;
    host = builtins.attrNames nixosConfigurations;
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

  homeConfigurations = builtins.mapAttrs (_:
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
