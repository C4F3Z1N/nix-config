{ config, inputs, lib, ... }:
let
  inherit (config.networking) hostName;
  prefix = lib.pipe config.environment [
    ({ persistence ? { "" = null; }, ... }: persistence)
    (builtins.attrNames)
    (builtins.head)
  ];
  GNUPGHOME = "${prefix}/opt/gnupg/${hostName}";
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  services.host-gpg-agent.homedir = GNUPGHOME;

  sops = rec {
    age.sshKeyPaths = lib.mkForce [ ];
    defaultSopsFile = "${inputs.secrets}/sops/hosts/${hostName}.json";
    gnupg = {
      inherit (age) sshKeyPaths;
      home = GNUPGHOME;
    };
  };
}
