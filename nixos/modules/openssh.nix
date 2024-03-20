{ config, lib, ... }:
let
  inherit (config.system.nixos) tags;
  impermanence = builtins.elem "impermanence" tags;
  prefix = lib.pipe config.environment.persistence [
    (lib.attrNames)
    (builtins.head)
    (lib.optionalString impermanence)
  ];
in {
  services.openssh = {
    hostKeys = map (type: {
      inherit type;
      path = "${prefix}/etc/ssh/ssh_host_${type}_key";
    }) [ "ecdsa" "ed25519" "rsa" ];

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };

    startWhenNeeded = true;
  };
}
