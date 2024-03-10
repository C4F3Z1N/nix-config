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
    hostKeys = [
      {
        path = "${prefix}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "${prefix}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
    ];

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
    };

    startWhenNeeded = true;
  };
}
