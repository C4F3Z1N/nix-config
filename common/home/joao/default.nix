{ inputs, lib, config, pkgs, ... }: {
  imports = [ ];

  home = {
    username = (builtins.baseNameOf ./.);
    homeDirectory = "/home/${config.home.username}";
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}
