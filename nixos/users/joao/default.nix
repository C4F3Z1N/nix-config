{ config, inputs, lib, pkgs, ... }:
let
  username = builtins.baseNameOf ./.;
  displayName = "João";
in {
  imports = [ ../. ];

  home-manager.users."${username}" =
    import (../../../home-manager + "/${username}");

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
      with lib.importJSON "${inputs.secrets}/public.json";
      users."${username}".ssh;
  };

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.ssh.startAgent = false;

  sops.secrets = let
    format = "json";
    neededForUsers = true;
    sopsFile = "${inputs.secrets}/sops/users/${username}.json";
  in lib.pipe sopsFile [
    (lib.importJSON)
    (lib.attrNames)
    (map (key:
      lib.mkIf (key != "sops") {
        "${username}/${key}" = { inherit format key neededForUsers sopsFile; };
      }))
    (lib.mkMerge)
  ];
}
