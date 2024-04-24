{ config, inputs, lib, ... }:
let
  inherit (config.system.nixos) tags;
  impermanence = builtins.elem "impermanence" tags;
  prefix = lib.optionalString impermanence (lib.pipe config.environment [
    ({ persistence ? { "" = null; }, ... }: persistence)
    (lib.attrNames)
    (builtins.head)
  ]);
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.age = {
    generateKey = false;
    sshKeyPaths = lib.pipe config.services.openssh.hostKeys [
      (builtins.filter ({ type, ... }: type == "ed25519"))
      (map (builtins.getAttr "path"))
    ];
  };
}
