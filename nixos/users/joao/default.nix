{ config, inputs, lib, pkgs, ... }:
let
  username = builtins.baseNameOf ./.;
  displayName = "João";
  sshPubKeys = lib.pipe "${inputs.secrets}/public-keys.json" [
    (lib.importJSON)
    (lib.getAttrFromPath [ "users" username ])
    (lib.filterAttrs (type: _: builtins.elem type [ "ecdsa" "ed25519" "rsa" ]))
    (builtins.attrValues)
  ];
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
    ] (builtins.attrNames config.users.groups);
    shell = pkgs.nushell;
    hashedPasswordFile = config.sops.secrets."${username}/password".path;
    openssh.authorizedKeys.keys = sshPubKeys;
  };

  sops.secrets = let
    format = "json";
    neededForUsers = true;
    sopsFile = "${inputs.secrets}/sops/users/${username}.json";
  in lib.pipe sopsFile [
    (lib.importJSON)
    (builtins.attrNames)
    (map (key:
      lib.mkIf (key != "sops") {
        "${username}/${key}" = { inherit format key neededForUsers sopsFile; };
      }))
    (lib.mkMerge)
  ];
}
