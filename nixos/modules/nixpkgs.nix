{ inputs, lib, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    # contentAddressedByDefault = true;
    packageOverrides = pkgs:
      let inherit (pkgs.stdenv.hostPlatform) system;
      in lib.pipe inputs [
        (lib.mapAttrsToList (_:
          { packages ? { }, legacyPackages ? { }, ... }:
          if packages != { } then packages else legacyPackages))
        (map (lib.attrByPath [ system "default" ] null))
        (map (default:
          lib.optionalAttrs (builtins.isAttrs default) {
            "${lib.getName default}" = default;
          }))
        (lib.attrsets.mergeAttrsList)
      ];
  };
}
