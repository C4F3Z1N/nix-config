{ config, lib, osConfig, pkgs, ... }: {
  home.packages = with pkgs; [
    libreoffice
    slack
    virt-manager
    virt-viewer
    vscode
  ];

  dconf.settings = lib.mkMerge [
    (lib.mkIf osConfig.services.xserver.desktopManager.gnome.enable {
      "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
      };
    })
    (lib.mkIf osConfig.virtualisation.libvirtd.enable {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    })
    (lib.mkIf config.programs.tmux.enable {
      "org/gnome/Console" = {
        shell = [ (lib.getExe config.programs.tmux.package) ];
      };
    })
  ];

  services.copyq.enable = true;
}
