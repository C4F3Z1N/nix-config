{ inputs, lib, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    # contentAddressedByDefault = true;
    packageOverrides = pkgs: lib.pipe inputs [
      (lib.mapAttrsToList (_:
        { packages ? { }, legacyPackages ? { }, ... }:
        if packages != { } then packages else legacyPackages))
      (builtins.catAttrs pkgs.stdenv.hostPlatform.system)
      (builtins.catAttrs "default")
      (map (package: lib.nameValuePair (lib.getName package) package))
      (builtins.listToAttrs)
    ];
  };
}
