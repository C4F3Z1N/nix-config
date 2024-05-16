{ config, inputs, lib, pkgs, ... }:
let
  inherit (config.networking) hostName;
  filterSshKeys =
    lib.filterAttrs (type: _: builtins.elem type [ "ecdsa" "ed25519" "rsa" ]);
  hostPubKeys = lib.pipe "${inputs.secrets}/public-keys.json" [
    (lib.importJSON)
    (builtins.getAttr "hosts")
    (builtins.mapAttrs (_: filterSshKeys))
  ];
  customKnownHosts = lib.pipe hostPubKeys [
    (lib.mapAttrsToList (name: keys:
      lib.pipe keys [ (builtins.attrValues) (map (key: "${name} ${key}")) ]))
    (lib.flatten)
    (lib.concatLines)
    (builtins.toFile "known_hosts")
  ];
in {
  services.openssh = {
    startWhenNeeded = true;

    # use public keys to force 'HostKeyAgent' lookup;
    hostKeys = lib.mapAttrsToList (type: key: {
      inherit type;
      path = builtins.toFile "${hostName}-${type}.pub" key;
    }) hostPubKeys."${hostName}";

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };
  };

  programs.ssh.knownHostsFiles = [ customKnownHosts ];
}
