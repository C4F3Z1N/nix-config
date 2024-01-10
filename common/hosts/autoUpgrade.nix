{ config, inputs, pkgs, lib, ... }: {
  system.autoUpgrade = {
    enable = inputs.self ? rev; # disable if dirty;
    dates = "hourly";
    flags = [ "--refresh" "--print-build-logs" ];
    flake = "github:c4f3z1n/nix-config";
  };

  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    serviceConfig.ExecCondition = pkgs.writeTextFile {
      name = "autoUpgrade-condition.nu";
      executable = true;
      text = ''
        #!${lib.getExe pkgs.nushell}
        use std assert
        def metadata [flake: string] {
          ^nix flake metadata $flake --refresh --json | from json
        }
        let upstream = metadata "${config.system.autoUpgrade.flake}"
        let local = metadata "${inputs.self}"
        assert ($upstream.locked.narHash != $local.locked.narHash)
        assert ($upstream.lastModified > $local.lastModified)
      '';
    };
  };
}
