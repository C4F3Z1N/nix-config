{ config, inputs, lib, ... }:
let
  inherit (config.networking) hostName;
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
    defaultSopsFile = "${inputs.secrets}/sops/hosts/${hostName}.json";
    gnupg = {
      inherit sshKeyPaths;
      home = "${prefix}/etc/gnupg";
    };
  };
}
