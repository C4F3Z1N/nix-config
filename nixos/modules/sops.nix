{ config, inputs, lib, ... }:
let
  prefix = lib.pipe config.environment [
    ({ persistence ? { "" = null; }, ... }: persistence)
    (lib.attrNames)
    (builtins.head)
  ];
  sshKeyPaths = lib.mkForce [ ];
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    age = { inherit sshKeyPaths; };
    gnupg = {
      inherit sshKeyPaths;
      home = "${prefix}/etc/gnupg";
    };
  };
}
