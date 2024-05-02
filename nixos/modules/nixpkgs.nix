{ inputs, lib, ... }: {
  nixpkgs = {
    config.allowUnfree = true;
    # config.contentAddressedByDefault = true;
    overlays = [
      # make packages from inputs available as pkgs.<name>;
      (final: prev:
        with prev.stdenv;
        lib.pipe inputs [
          (lib.mapAttrsToList (_:
            { packages ? { }, legacyPackages ? { }, ... }:
            if packages != { } then packages else legacyPackages))
          (builtins.catAttrs hostPlatform.system)
          (builtins.catAttrs "default")
          (map (package: lib.nameValuePair (lib.getName package) package))
          (builtins.listToAttrs)
        ])
    ];
  };
}
