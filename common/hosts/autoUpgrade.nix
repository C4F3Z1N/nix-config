{ config, inputs, pkgs, lib, ... }: {
  system.autoUpgrade = {
    enable = inputs.self ? rev;
    dates = "hourly";
    flags = [ "--refresh" "--update-input" "nixpkgs" "-L" ];
    flake = "github:c4f3z1n/nix-config";
  };

  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    serviceConfig.ExecCondition = let
      script = lib.getExe (with pkgs;
        writeShellApplication {
          name = "autoUpgrade-validator";
          runtimeInputs = [ nix yq-go ];
          text = ''
            lastModified() {
              nix flake metadata "$1" --refresh --json | yq '.lastModified'
            }

            local="$(lastModified ${inputs.self})"
            remote="$(lastModified ${config.system.autoUpgrade.flake})"

            test "$remote" -gt "$local"
          '';
        });
    in script;
  };
}
