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
      publicKeys = with lib.importJSON "${inputs.secrets}/public.json";
        map (text: {
          inherit text;
          trust = 5;
        }) users."${config.home.username}".gpg;
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
