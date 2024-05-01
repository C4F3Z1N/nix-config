{ config, inputs, lib, pkgs, ... }: {
  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };

    registry = with lib.importJSON ../../flake.lock; {
      secrets.to = builtins.removeAttrs nodes.secrets.locked [
        "lastModified"
        "narHash"
        "rev"
        "revCount"
        "shortRev"
      ];
      self.flake = inputs.self;
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "flakes" "nix-command" "repl-flake" ];
      flake-registry = import inputs.nix-registry { inherit pkgs; };
      nix-path = config.nix.nixPath;

      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
