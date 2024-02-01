{ config, inputs, lib, pkgs, ... }:
let
  # set 'outPath' to match the registry alias if 'inputs.self' is included;
  self = inputs.self // lib.optionalAttrs (lib.pipe config.nix.registry [
    (lib.attrValues)
    (builtins.any ({ flake, ... }: flake == inputs.self))
  ]) { outPath = "flake:self"; };
in {
  system.autoUpgrade = {
    enable = self ? rev; # disable if dirty;
    dates = "hourly";
    flags = [ "--refresh" "--print-build-logs" ];
    flake = "github:c4f3z1n/nix-config";
  };

  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    path = [ pkgs.nix ];
    serviceConfig.ExecCondition = pkgs.writeTextFile {
      name = "nixos-upgrade-condition.nu";
      executable = true;
      text = ''
        #!${lib.getExe pkgs.nushell}
        use std assert
        def metadata [flake: string] {
          ^nix flake metadata $flake --refresh --json | from json
        }
        let upstream = metadata "${config.system.autoUpgrade.flake}"
        let local = metadata "${self}"
        assert ($upstream.locked.narHash != $local.locked.narHash)
        assert ($upstream.lastModified > $local.lastModified)
      '';
    };
  };
}
