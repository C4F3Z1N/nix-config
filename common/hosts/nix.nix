{
  inputs,
  lib,
  ...
}: {
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than +3";
    };

    nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    settings = {
      auto-optimise-store = lib.mkDefault true;
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      flake-registry = null;
      warn-dirty = false;
    };
  };
}
