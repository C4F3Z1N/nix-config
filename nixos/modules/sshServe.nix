{ inputs, lib, ... }: {
  nix.sshServe.keys = lib.pipe "${inputs.secrets}/public-keys.json" [
    (lib.importJSON)
    ({ hosts, users, ... }: builtins.attrValues (hosts // users))
    (map (lib.filterAttrs
      (type: _: builtins.elem type [ "ecdsa" "ed25519" "rsa" ])))
    (map builtins.attrValues)
    (lib.flatten)
  ];
}
