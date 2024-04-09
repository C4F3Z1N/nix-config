{ config, inputs, lib, pkgs, ... }: {
  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };

    registry = let
      custom = import inputs.nix-registry { inherit pkgs; };
      upstream = lib.pipe custom [
        (lib.importJSON)
        (builtins.getAttr "flakes")
        (map (value@{ from, ... }: {
          inherit value;
          name = from.id;
        }))
        (builtins.listToAttrs)
      ];
      local = lib.pipe inputs [
        # remove entries that aren't flakes;
        (lib.filterAttrs (_: { _type ? null, ... }: _type == "flake"))
        (lib.mapAttrs (_: flake: { inherit flake; }))
      ];
    in local // upstream;

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "flakes" "nix-command" "repl-flake" ];
      flake-registry = null;
      nix-path = config.nix.nixPath;

      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
