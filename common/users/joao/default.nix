# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, inputs, lib, pkgs, ... }:
let
  username = builtins.baseNameOf ./.;
  displayName = "João";
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
  ];

  users.users."${username}" = {
    isNormalUser = true;
    description = displayName;
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    shell = pkgs.nushell;
    packages = with pkgs;
      [ (inputs.home-manager.packages."${system}".home-manager) ];
    hashedPasswordFile = config.sops.secrets."${username}/password".path;
  };

  environment.persistence."/keep" = {
    hideMounts = true;
    users."${username}" = {
      directories = [
        ".config"
        # ".gnupg"
        ".mozilla"
        ".ssh"
        ".vscode"
        "Desktop"
        "Development"
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
      ];
    };
  };

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.ssh.startAgent = false;

  sops.secrets = let
    fromJSON' = path: builtins.fromJSON (builtins.readFile path);
    removeSopsKey = set: lib.filterAttrs (key: _: key != "sops") set;

    format = "json";
    neededForUsers = true;
    sopsFile = ./secrets.json;
  in lib.mapAttrs' (key: _: {
    name = "${username}/${key}";
    value = { inherit format key neededForUsers sopsFile; };
  }) (removeSopsKey (fromJSON' sopsFile));

  home-manager.users."${username}" = import (../../home + "/${username}");
}
