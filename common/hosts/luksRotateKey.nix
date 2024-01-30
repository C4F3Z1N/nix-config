{ config, pkgs, lib, ... }:
let
  luks_password_file =
    config.sops.secrets."${config.networking.hostName}/luks_password".path;
in {
  systemd.services = lib.mapAttrs' (name: value:
    let
      inherit (value) device;
      svcName = "luks-rotatekey-${name}";
    in lib.nameValuePair svcName {
      enabled = true;
      startAt = [ "hourly" ];
      path = with pkgs; [ age coreutils cryptsetup lvm2.bin xxd ];
      serviceConfig = {
        Type = "oneshot";
        ExecCondition = pkgs.writeTextFile {
          name = "${svcName}-condition.nu";
          executable = true;
          text = ''
            #!${lib.getExe pkgs.nushell}
            assert false
            alias cryptsetup = ^cryptsetup --verbose
            def test_password [device: string, password_file: string] {
              let test_run = do {
                cryptsetup open --test-passphrase $device --key-file $password_file
              } | complete

              print $test_run.stdout

              if $test_run.exit_code > 0 {
                error make {msg: ""}
              } else {
                if not ($test_run.stderr | is-empty) {
                  print --stderr $test_run.stderr
                }
              }

              return $test_run.exit_code > 0
            }

            # let plainHeader = (mktemp -u)

            # cryptsetup luksHeaderBackup ${device} --header-backup-file $plainHeader


            # def metadata [flake: string] {
            #   ^nix flake metadata $flake --refresh --json | from json
            # }
            # let upstream = metadata "${config.system.autoUpgrade.flake}"
            # let local = metadata "${inputs.self}"
            # assert ($upstream.locked.narHash != $local.locked.narHash)
            # assert ($upstream.lastModified > $local.lastModified)
          '';
        };
        # ExecStart = pkgs.writeTextFile {
        #   name = "${svcName}.nu";
        #   executable = true;
        #   text = ''
        #     #!${lib.getExe pkgs.nushell}
        #     use std assert
        #     def metadata [flake: string] {
        #       ^nix flake metadata $flake --refresh --json | from json
        #     }
        #     let upstream = metadata "${config.system.autoUpgrade.flake}"
        #     let local = metadata "${inputs.self}"
        #     assert ($upstream.locked.narHash != $local.locked.narHash)
        #     assert ($upstream.lastModified > $local.lastModified)
        #   '';
        # };
      };
    }) config.boot.initrd.luks.devices;

  # systemd.services.luks-key-rotation = lib.mkIf (builtins.length devices > 0) {
  #   enabled = true;
  #   startAt = [ "hourly" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecCondition = "";
  #     ExecStart = "";
  #   };
  # };
  # lib.mkIf (config.system.autoUpgrade.enable) {
  # serviceConfig.ExecCondition = pkgs.writeTextFile {
  #   name = "rotation-condition.nu";
  #   executable = true;
  #   text = ''
  #     #!${lib.getExe pkgs.nushell}
  #     use std assert
  #     def metadata [flake: string] {
  #       ^nix flake metadata $flake --refresh --json | from json
  #     }
  #     let upstream = metadata "${config.system.autoUpgrade.flake}"
  #     let local = metadata "${inputs.self}"
  #     assert ($upstream.locked.narHash != $local.locked.narHash)
  #     assert ($upstream.lastModified > $local.lastModified)
  #   '';
  # };
  # };
  # check if there is luks;
}

# [Unit]
# After=network-online.target
# Description=NixOS Upgrade
# Wants=network-online.target
# X-StopOnRemoval=false

# [Service]
# Environment="HOME=/root"
# Environment="LOCALE_ARCHIVE=/nix/store/dlpnxprcacndawgjz63qhhvfjwdg9726-glibc-locales-2.38-27/lib/locale/locale-archive"
# Environment="NIX_PATH=nixpkgs=/nix/store/2xgpqy6dyicqnhwym6nnaysd8mzrwkr8-source"
# Environment="PATH=/nix/store/m38gwq0w8w7qyjn9s00balyp7cv3m5p9-coreutils-9.3/bin:/nix/store/mi3pm67ps7c7k11aqki9182ygzg8j503-gnutar-1.35/bin:/nix/store/3q6fnwcm677l1q60vkhcf9m1gxhv83jm-xz-5.4.4-bin/bin:/nix/store/5c0ancqnpi0cf1h49mv13w68a950s9z0-gzip-1.13/bin:/nix/store/88rn32f5nkpl7h8r5i5mvj5g4w11flbw-git-minimal-2.42.0/bin:/nix/store/j7nl2pj606d8ld5818hw3z3fbz00sdc5-nix-2.18.1/bin:/nix/store/3ygr1pbxj1377drq84x0fdm4d0j0d7pz-openssh-9.6p1/bin:/nix/store/m38gwq0w8w7qyjn9s00balyp7cv3m5p9-coreutils-9.3/bin:/nix/store/01znf87kiw5xx1dj0f7djrnrbg84ij28-findutils-4.9.0/bin:/nix/store/n062zcsmfl9gfp6vfkcg0asb8jjwmy5i-gnugrep-3.11/bin:/nix/store/rwa7qyds01qzxvq7zq3kgnkrzzpw4s66-gnused-4.9/bin:/nix/store/5l8bhmhp0kf5pbi7npjng7iszscfh19z-systemd-254.6/bin:/nix/store/m38gwq0w8w7qyjn9s00balyp7cv3m5p9-coreutils-9.3/sbin:/nix/store/mi3pm67ps7c7k11aqki9182ygzg8j503-gnutar-1.35/sbin:/nix/store/3q6fnwcm677l1q60vkhcf9m1gxhv83jm-xz-5.4.4-bin/sbin:/nix/store/5c0ancqnpi0cf1h49mv13w68a950s9z0-gzip-1.13/sbin:/nix/store/88rn32f5nkpl7h8r5i5mvj5g4w11flbw-git-minimal-2.42.0/sbin:/nix/store/j7nl2pj606d8ld5818hw3z3fbz00sdc5-nix-2.18.1/sbin:/nix/store/3ygr1pbxj1377drq84x0fdm4d0j0d7pz-openssh-9.6p1/sbin:/nix/store/m38gwq0w8w7qyjn9s00balyp7cv3m5p9-coreutils-9.3/sbin:/nix/store/01znf87kiw5xx1dj0f7djrnrbg84ij28-findutils-4.9.0/sbin:/nix/store/n062zcsmfl9gfp6vfkcg0asb8jjwmy5i-gnugrep-3.11/sbin:/nix/store/rwa7qyds01qzxvq7zq3kgnkrzzpw4s66-gnused-4.9/sbin:/nix/store/5l8bhmhp0kf5pbi7npjng7iszscfh19z-systemd-254.6/sbin"
# Environment="TZDIR=/nix/store/4dbixfbbm2vl5jsl7xr7pbp71amf4x9r-tzdata-2023c/share/zoneinfo"
# X-RestartIfChanged=false
# ExecCondition=/nix/store/l0l0h84k65vaksxnv4m0pr69v011dpcn-autoUpgrade-condition.nu
# ExecStart=/nix/store/rfh18wxjsg7ldifw2kf01xgkp7jvifpk-unit-script-nixos-upgrade-start/bin/nixos-upgrade-start
# Type=oneshot
