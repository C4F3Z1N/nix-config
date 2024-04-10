{ config, inputs, lib, pkgs, ... }: {
  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };

    registry = with inputs;
      let
        upstream = lib.importJSON (import nix-registry { inherit pkgs; });
        local = lib.importJSON (import nix-registry {
          inherit pkgs;
          lockFile = "${self}/flake.lock";
        });
        consolidated = lib.pipe (local.flakes ++ upstream.flakes) [
          (map (value@{ from, ... }: {
            inherit value;
            name = from.id;
          }))
          (builtins.listToAttrs)
        ];
      in consolidated // { self.flake = self; };

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
