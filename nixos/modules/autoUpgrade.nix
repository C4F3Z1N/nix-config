{ config, lib, pkgs, ... }:
let
  environment = lib.pipe config.environment [
    ({ sessionVariables, variables, ... }: variables // sessionVariables)
    (lib.filterAttrs
      (name: _: builtins.elem name [ "GNUPGHOME" "SSH_AUTH_SOCK" ]))
  ];
in {
  system.autoUpgrade = {
    dates = "hourly";
    flags = [ "--print-build-logs" ];
    flake = "github:c4f3z1n/nix-config";
  };

  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    inherit environment;
    path = with pkgs; [ nix nushell ];
    serviceConfig.ExecCondition = pkgs.writeTextFile {
      executable = true;
      name = "nixos-upgrade-condition.nu";
      text = ''
        #!/usr/bin/env nu
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
          assert ("revision" in $local)
          assert ($upstream == $latest)
        }
      '';
    };
  };
}
