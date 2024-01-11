{ lib, osConfig, pkgs, ... }: {
  home.packages = with pkgs; [ slack virt-manager vscode ];

  dconf.settings = with osConfig;
    lib.mkMerge [
      (lib.mkIf services.xserver.desktopManager.gnome.enable {
        "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
        };
      })
      (lib.mkIf virtualisation.libvirtd.enable {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };
      })
    ];
}
