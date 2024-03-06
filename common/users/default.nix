{ config, inputs, lib, ... }: {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.etc.shells.text = lib.pipe config.users.users [
    (lib.mapAttrs (username:
      { shell, ... }:
      let
        inherit (shell) shellPath;
        altPath = "/run/current-system/sw${shellPath}";
        exePath = lib.getExe shell;
        shellName = lib.getName shell;
      in lib.optionalString (username != "root" && shellName != "shadow") ''
        # ${username}'s shell;
        ${exePath}
        ${altPath}
      ''))
    (lib.attrValues)
    (builtins.toString)
  ];
}
