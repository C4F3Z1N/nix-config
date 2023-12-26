# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "joao";
  displayName = "João";
in {
  sops.secrets = {
    "${username}/password" = {
      format = "json";
      key = "password";
      neededForUsers = true;
      sopsFile = ./secrets.json;
    };
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = displayName;
    extraGroups = ["docker" "networkmanager" "wheel"];
    # shell = pkgs.nushell;
    packages = with pkgs; [firefox-esr];
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
  services.udev.packages = [pkgs.yubikey-personalization];

  programs.ssh.startAgent = false;
}
