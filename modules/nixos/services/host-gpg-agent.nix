{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.host-gpg-agent;
  envVars = {
    GNUPGHOME = cfg.homedir;
    SSH_AUTH_SOCK = "/run/host-gpg-agent/S.gpg-agent.ssh";
  };
in {
  options.services.host-gpg-agent = with types; {
    enable = mkOption {
      type = bool;
      default = false;
    };

    homedir = mkOption {
      type = path;
      default = "/etc/gnupg";
    };

    package = mkOption {
      type = package;
      default = config.programs.gnupg.package;
    };

    verbose = mkOption {
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    nix = { inherit envVars; };

    environment.etc."ssh/sshd_config.d/host-gpg-agent.conf".text =
      "HostKeyAgent ${envVars.SSH_AUTH_SOCK}";

    programs.ssh.extraConfig = ''
      # The SSH agent protocol doesn't have support for changing TTYs; however we
      # can simulate this with the `exec` feature of openssh (see ssh_config(5))
      # that hooks a command to the shell currently running the ssh program.
      Match host * exec "${cfg.package}/bin/gpg-connect-agent --quiet updatestartuptty /bye"
    '';

    services.openssh.extraConfig =
      mkAfter "Include /etc/ssh/sshd_config.d/host-gpg-agent.conf";

    systemd = {
      services = {
        host-gpg-agent = rec {
          after = requires;
          environment = envVars;
          requires = [ "host-gpg-agent-ssh.socket" "host-gpg-agent.socket" ];
          serviceConfig = {
            ExecReload = "${cfg.package}/bin/gpgconf --reload gpg-agent";
            ExecStart = "${cfg.package}/bin/gpg-agent --supervised"
              + optionalString cfg.verbose " --verbose";
          };
          unitConfig.RefuseManualStart = true;
        };
      };

      sockets = {
        host-gpg-agent = {
          partOf = [ "host-gpg-agent.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = rec {
            DirectoryMode = "0700";
            ExecStartPre = "${pkgs.coreutils}/bin/rm -fv ${Symlinks}";
            FileDescriptorName = "std";
            ListenStream = "/run/host-gpg-agent/S.gpg-agent";
            SocketMode = "0600";
            Symlinks = "${cfg.homedir}/${builtins.baseNameOf ListenStream}";
          };
        };

        host-gpg-agent-ssh = {
          partOf = [ "host-gpg-agent.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = rec {
            DirectoryMode = "0700";
            ExecStartPre = "${pkgs.coreutils}/bin/rm -fv ${Symlinks}";
            FileDescriptorName = "ssh";
            ListenStream = envVars.SSH_AUTH_SOCK;
            Service = "host-gpg-agent.service";
            SocketMode = "0600";
            Symlinks = "${cfg.homedir}/${builtins.baseNameOf ListenStream}";
          };
        };
      };
    };
  };
}
