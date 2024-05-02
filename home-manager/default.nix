{ inputs, lib }:
let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (inputs.self) nixosConfigurations;

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
in builtins.mapAttrs (_:
  { modulePath, nixosHost }:
  homeManagerConfiguration {
    inherit (nixosHost) pkgs;
    extraSpecialArgs = {
      inherit inputs;
      osConfig = nixosHost.config;
    };
    modules = [ modulePath ];
  }) combinations
