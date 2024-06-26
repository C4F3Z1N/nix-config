{ config, lib, osConfig, pkgs, ... }:
let isGnome = osConfig.services.xserver.desktopManager.gnome.enable;
in {
  home.packages = with pkgs; [
    libreoffice
    slack
    virt-manager
    virt-viewer
    vlc
    vscode
  ];

  dconf.settings = lib.mkMerge [
    (lib.mkIf isGnome {
      "org/gnome/Console" = {
        font-scale = 1.3;
        shell = lib.optionals config.programs.tmux.enable [ "tmux" "attach" ];
      };
      "org/gnome/desktop/datetime".automatic-timezone = true;
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/mutter".experimental-features =
        [ "scale-monitor-framebuffer" ];
      "org/gnome/settings-daemon/plugins/color".night-light-enabled = true;
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/CopyQ/"
        ];
        home = [ "<Super>e" ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/CopyQ" =
        {
          name = "CopyQ";
          binding = "<Super>q";
          command = "copyq toggle";
        };
      "org/gnome/system/location".enabled = osConfig.services.geoclue2.enable;
    })
    (lib.mkIf osConfig.virtualisation.libvirtd.enable {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    })
  ];

  services.copyq.enable = true;
  services.gpg-agent.pinentryPackage = lib.mkIf isGnome pkgs.pinentry-gnome;
}
