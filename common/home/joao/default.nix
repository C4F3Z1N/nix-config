{ config, lib, osConfig, pkgs, ... }: {
  imports = lib.flatten [
    [
      ./containers.nix
      ./keyring.nix
      ./misc-cli.nix
      ./shells.nix
    ]

    # don't import if the host is headless;
    (lib.optionals osConfig.services.xserver.enable [
      ./browsers.nix
      ./misc-gui.nix
    ])
  ];

  home = {
    username = builtins.baseNameOf ./.;
    homeDirectory = "/home/${config.home.username}";

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = if pkgs.config.allowUnfree then "1" else "0";
    };
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = with lib; (versions.majorMinor version);
}
