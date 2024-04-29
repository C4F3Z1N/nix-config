{ config, inputs, lib, pkgs, ... }:
let
  inherit (config.networking) hostName;
  inherit (config.system.nixos) tags;
  impermanence = builtins.elem "impermanence" tags;
  prefix = lib.optionalString impermanence (lib.pipe config.environment [
    ({ persistence ? { "" = null; }, ... }: persistence)
    (lib.attrNames)
    (builtins.head)
  ]);
  filterSshKeys =
    lib.filterAttrs (type: _: builtins.elem type [ "ecdsa" "ed25519" "rsa" ]);
  hostPubKeys = lib.pipe "${inputs.secrets}/public-keys.json" [
    (lib.importJSON)
    (builtins.getAttr "hosts")
    (lib.mapAttrs (_: keys: filterSshKeys keys))
  ];
in {
  services.openssh = {
    startWhenNeeded = true;

    hostKeys = map (type: {
      inherit type;
      path = "${prefix}/etc/ssh/ssh_host_${type}_key";
    }) [ "ecdsa" "ed25519" "rsa" ];

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };
  };

  programs.ssh.knownHostsFiles = lib.pipe hostPubKeys [
    (lib.mapAttrsToList (name: keys:
      lib.pipe keys [ (lib.attrValues) (map (key: "${name} ${key}")) ]))
    (lib.flatten)
    (lib.concatLines)
    (pkgs.writeText "known_hosts")
    (lib.singleton)
  ];
}
