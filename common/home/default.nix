{ inputs }:
let
  lib = with inputs; (nixpkgs.lib // home-manager.lib);

  dirContent = path:
    lib.pipe path [
      (builtins.readDir)
      (lib.mapAttrs (name: _: path + "/${name}"))
      (lib.filterAttrs (name: _: name != "default.nix"))
    ];

  inherit (inputs.self) nixosConfigurations;
  homeConfigurations = dirContent ./.;

  entries = lib.pipe {
    user = homeConfigurations;
    host = nixosConfigurations;
  } [
    # get user and host names using lib.attrNames;
    (lib.mapAttrs (_: value: lib.attrNames value))
    # create all possible combinations of user + host;
    (lib.cartesianProductOfSets)
    # convert to named list entries;
    (map ({ user, host }:
      lib.nameValuePair "${user}@${host}" {
        modulePath = homeConfigurations."${user}";
        nixosHost = nixosConfigurations."${host}";
      }))
    # convert list to attrSet;
    (builtins.listToAttrs)
    # convert to homeManagerConfiguration entries;
    (lib.mapAttrs (_:
      { modulePath, nixosHost }:
      lib.homeManagerConfiguration {
        inherit (nixosHost) pkgs;
        extraSpecialArgs = {
          inherit inputs;
          osConfig = nixosHost.config;
        };
        modules = [ modulePath ];
    }))
  ];
in entries
