{ config, ... }: {
  programs = {
    gpg = {
      enable = true;
      publicKeys = [{
        source = builtins.fetchurl {
          url =
            "https://keys.openpgp.org/vks/v1/by-fingerprint/724A264781B08135FE89E9FDBE4D78290B7222EA";
          sha256 =
            "sha256:07zakjijajnczrsrz0bihl1ay0gcj8z5i4sm18s8bjr9mmip33k6";
        };
        trust = 5;
      }];
    };

    ssh = {
      enable = true;
      controlMaster = "auto";
      controlPath = "${config.xdg.cacheHome}/ssh-%r@%h:%p";
      controlPersist = "1h";
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
