{ config, lib, osConfig, pkgs, ... }: {
  imports = lib.flatten [
    [
      ./containers.nix
      ./keyring.nix
      ./misc-cli.nix
      ./shells.nix
    ]

    # don't import if the host is headless;
    (lib.optionals (!builtins.elem "headless" osConfig.system.nixos.tags) [
      ./browsers.nix
      ./misc-gui.nix
    ])
  ];

  home = {
    inherit (osConfig.system) stateVersion;

    username = builtins.baseNameOf ./.;
    homeDirectory = "/home/${config.home.username}";

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = if pkgs.config.allowUnfree then "1" else "0";
    };
  };

  fonts.fontconfig = { inherit (osConfig.fonts.fontconfig) enable; };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
