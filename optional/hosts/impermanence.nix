{ inputs, ... }: {
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence."/keep" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/log"
    ];
    files = [ "/etc/machine-id" ];
  };

  fileSystems."/keep".neededForBoot = true;

  programs.fuse.userAllowOther = true;

  system.nixos.tags = [ "impermanence" ];
}
