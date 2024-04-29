{ config, inputs, lib, pkgs, ... }: {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.etc.shells.text = lib.pipe config.users.users [
    (lib.attrValues)
    (builtins.filter ({ isNormalUser, ... }: isNormalUser))
    (map ({ shell, ... }:
      let
        inherit (shell) shellPath;
        altPath = "/run/current-system/sw${shellPath}";
        exePath = lib.getExe shell;
        shellName = lib.getName shell;
      in [ exePath altPath ]))
    (lib.flatten)
    (lib.concatLines)
  ];

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.ssh.startAgent = false;
}
