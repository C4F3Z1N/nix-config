{ config, inputs, osConfig, ... }: {
  imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

  home.persistence = {
    "/keep${config.home.homeDirectory}" = {
      allowOther = osConfig.programs.fuse.userAllowOther;

      directories = [
        ".mozilla"
        ".ssh"
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
        "gcloud"
        "home-manager"
        "Slack"
        "sops"
      ];

      files = map (f: ".config/${f}") [
        "monitors.xml"
        "monitors.xml~"
        "nushell/history.txt"
      ];
    };
  };
}
