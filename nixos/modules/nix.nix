{ config, inputs, lib, ... }: {
  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };

    registry = let
      upstream = lib.pipe inputs.nix-registry [
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
        (lib.mapAttrs (name: flake: { inherit flake; }))
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
