{ inputs }:
let
  lib = with inputs; (nixpkgs.lib // home-manager.lib);

  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (inputs.self) nixosConfigurations;

  dirContent = path:
    lib.pipe path [
      (builtins.readDir)
      (lib.mapAttrs (name: _: path + "/${name}"))
      (lib.filterAttrs (name: _: name != "default.nix"))
    ];

  homeConfigurations = dirContent ./.;

  entries = lib.pipe {
    user = homeConfigurations;
    host = nixosConfigurations;
  } [
    # get user and host names using lib.attrNames;
    (lib.mapAttrs (_: value: lib.attrNames value))
    # create all possible combinations of user + host;
    (lib.cartesianProductOfSets)
    # create config entries for each combination;
    (map ({ user, host }: {
      "${user}@${host}" = let
        modulePath = homeConfigurations."${user}";
        nixosHost = nixosConfigurations."${host}";
      in homeManagerConfiguration {
        inherit (nixosHost) pkgs;
        extraSpecialArgs = {
          inherit inputs;
          osConfig = nixosHost.config;
        };
        modules = [ modulePath ];
      };
    }))
    # convert list to attrSet;
    (lib.attrsets.mergeAttrsList)
  ];
in entries
