{ config, inputs, lib, osConfig, ... }:
let
  allowOther = osConfig.programs.fuse.userAllowOther;
  mountPoints = lib.attrNames osConfig.environment.persistence;
  mainPath = (builtins.head mountPoints) + config.home.homeDirectory;
in {
  imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

  home.persistence."${mainPath}" = {
    inherit allowOther;

    directories = [
      ".mozilla"
      ".ssh"
      ".tmux"
      ".vscode"
      "Desktop"
      "Development"
      "Documents"
      "Downloads"
      "Pictures"
      "Videos"
    ] ++ map (d: ".config/${d}") [
      "chromium"
      "Code"
      "copyq"
      "gcloud"
      "home-manager"
      "qutebrowser"
      "rclone"
      "Slack"
      "sops"
    ] ++ map (d: ".local/share/${d}") [ "direnv" "nix" "pueue" "qutebrowser" ];

    files = map (f: ".config/${f}") [
      "monitors.xml"
      "monitors.xml~"
      "nushell/history.txt"
    ];
  };
}
