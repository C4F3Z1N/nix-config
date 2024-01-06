{ config, ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST1000LM049-2GH172_WN92WRCK";
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
                name = "crypted";
                settings.allowDiscards = true;
                passwordFile = "/tmp/luks_password.txt";
                content = {
                  type = "gpt";
                  partitions = {
                    swap = {
                      size = "17G";
                      content = {
                        type = "swap";
                        resumeDevice = true;
                      };
                    };

                    zfs = {
                      size = "100%";
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
          mountpoint = "none";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
        };

        datasets = {
          ephemeral = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              mountpoint = "none";
            };
          };

          persistent = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              mountpoint = "none";
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

          "persistent/zvol" = {
            type = "zfs_volume";
            size = "150G";
            # content = {
            #   type = "nodev";
            #   # resumeDevice = true;
            # };
          };
        };
      };
    };
  };
}
