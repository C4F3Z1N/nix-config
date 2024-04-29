{ config, inputs, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    age
    john
    monkeysphere
    openssl
    pgpdump
    sops
    ssh-to-age
    ssh-to-pgp
    yubikey-manager
  ];

  programs = {
    gpg = {
      enable = true;
      publicKeys = lib.pipe "${inputs.secrets}/public-keys.json" [
        (lib.importJSON)
        ({ hosts, users, ... }: hosts // users)
        (lib.attrValues)
        (lib.catAttrs "pgp")
        (map (text: {
          inherit text;
          trust = 5;
        }))
      ];
    };

    ssh = {
      enable = true;
      controlMaster = "auto";
      controlPath = "${config.xdg.cacheHome}/ssh-%r@%h:%p.sock";
      controlPersist = "15m";
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableScDaemon = true;
    };

    ssh-agent.enable = false;
  };
}
