{ inputs, lib ? (import <nixpkgs> { }).lib }:
let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (inputs.self) nixosConfigurations;

  readDir' = path:
    lib.mapAttrs (found: _: path + "/${found}") (builtins.readDir path);

  homeConfigurations =
    (lib.filterAttrs (name: _: name != "default.nix") (readDir' ./.));
  combinations = lib.cartesianProductOfSets {
    user = lib.attrNames homeConfigurations;
    host = lib.attrNames nixosConfigurations;
  };
  entries = lib.attrsets.mergeAttrsList (map ({ user, host }: {
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
  }) combinations);
in entries
