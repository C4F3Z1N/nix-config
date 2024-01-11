{ inputs, lib, ... }: {
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    registry = lib.pipe inputs [
      # remove inputs that aren't flakes;
      (lib.filterAttrs (_: value: value ? _type && value._type == "flake"))
      (lib.mapAttrs (_: value: { flake = value; }))
    ];

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "flakes" "nix-command" "repl-flake" ];
      flake-registry = null;
      warn-dirty = false;

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      substituters =
        [ "https://cache.nixos.org" "https://nixpkgs-wayland.cachix.org" ];
    };
  };
}
