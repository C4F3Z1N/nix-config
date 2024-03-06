{ config, inputs, ... }: {
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.ace42e000a9f5cf42ee4ac0000000001";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };

            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                passwordFile = config.sops.secrets.luks_password.path;
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          compression = "zstd";
          dnodesize = "auto";
          mountpoint = "legacy";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
        };

        datasets = {
          ephemeral = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              mountpoint = "legacy";
            };
          };

          persistent = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              mountpoint = "legacy";
            };
          };

          "ephemeral/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs snapshot zroot/ephemeral/root@blank";
          };

          "persistent/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };

          "persistent/storage" = {
            type = "zfs_fs";
            mountpoint = "/keep";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
