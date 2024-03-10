{ config, lib, ... }:
let
  inherit (config.system.nixos) tags;
  impermanence = builtins.elem "impermanence" tags;
  prefix = lib.optionalString impermanence "/keep";
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
