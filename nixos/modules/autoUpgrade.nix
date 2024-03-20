{ config, lib, pkgs, ... }: {
  system.autoUpgrade = {
    enable = self ? rev; # disable if dirty;
    dates = "hourly";
    flags = [ "--print-build-logs" "--refresh" ];
    flake = "git+ssh://git@github.com/c4f3z1n/nix-config.git";
  };

  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    # use hostKeys to connect git+ssh;
    environment.GIT_SSH_COMMAND = lib.pipe config.services.openssh.hostKeys [
      (map ({ path, ... }: "-i ${path}"))
      (builtins.toString)
      (keyArgs: "ssh -v ${keyArgs}")
    ];
    path = with pkgs; [ gitMinimal nix nushell openssh ];
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
        let upstream = metadata "${config.system.autoUpgrade.flake}"
        let local = metadata "flake:self"
        let latest = [ $upstream, $local ] | sort-by lastModified | last
        assert ($upstream == $latest)
      '';
    };
  };
}
