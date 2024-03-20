{ inputs, config, lib, pkgs, ... }:
let
  inherit (config.system.nixos) tags;
  impermanence = builtins.elem "impermanence" tags;
  prefix = lib.pipe config.environment.persistence [
    (lib.attrNames)
    (builtins.head)
    (lib.optionalString impermanence)
  ];
  githubKnownHosts = lib.pipe inputs.github-metadata [
    (lib.importJSON)
    ({ ssh_keys, ... }: map (key: "github.com ${key}") ssh_keys)
    (lib.concatLines)
    (pkgs.writeText "known_hosts-github.com")
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

  programs.ssh = {
    extraConfig = lib.pipe config.services.openssh.hostKeys [
      (map ({ path, ... }: "IdentityFile ${path}"))
      (lib.concatLines)
    ];
    knownHostsFiles = lib.mkAfter [ githubKnownHosts ];
  };
}
