{ config, lib, pkgs, ... }:
let
  GNUPGHOME = config.sops.gnupg.home;
  SSH_AUTH_SOCK = "${GNUPGHOME}/S.gpg-agent.ssh";
in {
  systemd = {
    services.host-gpg-agent = rec {
      environment = { inherit GNUPGHOME; };
      after = requires;
      requires = [ "host-gpg-agent-ssh.socket" "host-gpg-agent.socket" ];
      serviceConfig = {
        ExecReload = "${pkgs.gnupg}/bin/gpgconf --reload gpg-agent";
        ExecStart = "${pkgs.gnupg}/bin/gpg-agent --supervised";
      };
      # unitConfig.RefuseManualStart = true;
    };

    sockets = {
      host-gpg-agent = {
        partOf = [ "host-gpg-agent.service" ];
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          DirectoryMode = "0700";
          FileDescriptorName = "std";
          ListenStream = "${GNUPGHOME}/S.gpg-agent";
          SocketMode = "0600";
        };
      };

      host-gpg-agent-ssh = {
        partOf = [ "host-gpg-agent.service" ];
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          DirectoryMode = "0700";
          FileDescriptorName = "ssh";
          ListenStream = SSH_AUTH_SOCK;
          Service = "host-gpg-agent.service";
          SocketMode = "0600";
        };
      };
    };
  };

  environment.sessionVariables = { inherit GNUPGHOME SSH_AUTH_SOCK; };

  services.openssh.extraConfig = "HostKeyAgent ${SSH_AUTH_SOCK}";
}
