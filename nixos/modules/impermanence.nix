{ config, inputs, lib, ... }:
let
  filePath = ../../hosts + "/${config.networking.hostName}/persistence.json";
  persistence = lib.importJSON filePath;
  mountPoints = lib.attrNames persistence;
in {
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment = { inherit persistence; };

  fileSystems = lib.genAttrs mountPoints (_: { neededForBoot = true; });

  programs.fuse.userAllowOther = true;

  system.nixos.tags = [ "impermanence" ];
}
