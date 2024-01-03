{ config, lib, pkgs, ... }: {
  imports = [
    ./browsers.nix
    ./containers.nix
    ./keyring.nix
    ./misc-cli.nix
    ./misc-gui.nix
    ./shells.nix
  ];

  home = {
    username = builtins.baseNameOf ./.;
    homeDirectory = "/home/${config.home.username}";

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = if pkgs.config.allowUnfree then 1 else 0;
    };
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = with lib; (versions.majorMinor version);
}
