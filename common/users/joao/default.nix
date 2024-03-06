{ config, inputs, lib, pkgs, ... }:
let
  username = builtins.baseNameOf ./.;
  displayName = "João";
in {
  imports = [ ../. ];

  users.users."${username}" = {
    isNormalUser = true;
    description = displayName;
    extraGroups = lib.intersectLists [
      # add user to the groups below if they exist;
      "docker"
      "libvirtd"
      "lxd"
      "networkmanager"
      "podman"
      "wheel"
    ] (lib.attrNames config.users.groups);
    shell = pkgs.nushell;
    hashedPasswordFile = config.sops.secrets."${username}/password".path;
    openssh.authorizedKeys.keys =
      lib.splitString "\n" (builtins.readFile inputs.my-keys);
  };

  environment.persistence."/keep" = {
    hideMounts = true;
    users."${username}" = {
      directories = [
        ".mozilla"
        ".ssh"
        ".vscode"
        "Desktop"
        "Development"
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
      ] ++ map (d: ".config/${d}") [
        "chromium"
        "Code"
        "gcloud"
        "home-manager"
        "Slack"
        "sops"
      ];

      files = map (f: ".config/${f}") [
        "monitors.xml"
        "monitors.xml~"
        "nushell/history.txt"
      ];
    };
  };

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.ssh.startAgent = false;

  sops.secrets = let
    format = "json";
    neededForUsers = true;
    sopsFile = ./secrets.json;
  in lib.pipe sopsFile [
    (lib.importJSON)
    (lib.attrNames)
    (map (key:
      lib.mkIf (key != "sops") {
        "${username}/${key}" = { inherit format key neededForUsers sopsFile; };
      }))
    (lib.mkMerge)
  ];

  home-manager.users."${username}" = import (../../home + "/${username}");
}
