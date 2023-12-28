{ inputs, lib, config, pkgs, ... }: {
  imports = [ ./browsers.nix ./keyring.nix ./misc.nix ./shells.nix ];

  home = {
    username = builtins.baseNameOf ./.;
    homeDirectory = "/home/${config.home.username}";

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE =
        builtins.toString (config.nixpkgs.config.allowUnfree);
    };
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = with lib; (versions.majorMinor version);
}
