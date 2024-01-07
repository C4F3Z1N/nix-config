{ lib, osConfig, pkgs, ... }: {
  home.packages = with pkgs; [ slack virt-manager vscode ];

  dconf.settings = lib.mkIf osConfig.virtualisation.libvirtd.enable {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
