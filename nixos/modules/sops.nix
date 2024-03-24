{ config, inputs, lib, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.age = {
    generateKey = false;
    sshKeyPaths = lib.pipe config.services.openssh.hostKeys [
      (builtins.filter ({ type, ... }: type == "ed25519"))
      (map (builtins.getAttr "path"))
    ];
  };
}
