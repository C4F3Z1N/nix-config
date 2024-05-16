{ config, lib, pkgs, ... }: {
  system.autoUpgrade = {
    dates = "hourly";
    flags = [ "--print-build-logs" ];
    flake = "git+ssh://git@github.com/c4f3z1n/nix-config.git";
  };

  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    serviceConfig.ExecCondition = pkgs.writeTextFile {
      executable = true;
      name = "nixos-upgrade-condition.nu";
      text = ''
        #!${lib.getExe pkgs.nushell}
        use std assert
        def metadata [flake: string]: string -> record {
          let output = do { ^nix flake metadata $flake --refresh --json } | complete
          assert ($output.exit_code == 0) $output.stderr
          return ($output.stdout | from json)
        }
        def main []: nothing -> nothing {
          let upstream = metadata "${config.system.autoUpgrade.flake}"
          let local = metadata "flake:self"
          let latest = [ $upstream, $local ] | sort-by lastModified | last
          assert ("revision" in $local) "'flake:self' is dirty."
          assert ($upstream == $latest) "'upstream' is older than 'flake:self'."
        }
      '';
    };
  };
}
