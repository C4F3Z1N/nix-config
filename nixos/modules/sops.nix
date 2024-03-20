{ config, inputs, lib, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.age = {
    sshKeyPaths = lib.pipe config.services.openssh.hostKeys [
      (builtins.filter ({ type, ... }: type == "ed25519"))
      (map (builtins.getAttr "path"))
    ];
    generateKey = false;
  };
}
