{ config, inputs, ... }:
let
  isEd25519 = key: key.type == "ed25519";
  ed25519HostKeys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.age = {
    sshKeyPaths = map (builtins.getAttr "path") ed25519HostKeys;
    generateKey = false;
  };
}
