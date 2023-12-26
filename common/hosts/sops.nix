{
  config,
  inputs,
  ...
}: let
  isEd25519 = key: key.type == "ed25519";
  keyPath = key: key.path;
  ed25519HostKeys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in {
  imports = [inputs.sops.nixosModules.sops];

  sops.age = {
    sshKeyPaths = map keyPath ed25519HostKeys;
    generateKey = false;
  };
}
