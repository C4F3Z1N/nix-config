{ inputs, lib, ... }: {
  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };

    registry = let
      upstream = inputs.nix-registry.final;
      local = lib.pipe inputs [
        # remove inputs that aren't flakes;
        (lib.filterAttrs (_: { _type ? null, ... }: _type == "flake"))
        (lib.mapAttrs (name: flake: { inherit flake; }))
      ];
    in local // upstream;

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "flakes" "nix-command" "repl-flake" ];
      flake-registry = null;

      substituters =
        [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
