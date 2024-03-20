{ config, lib, osConfig, pkgs, ... }:
let
  inherit (osConfig.system.nixos) tags;
  headless = builtins.elem "headless" tags;
in {
  programs = {
    bash.enable = true;
    carapace.enable = true;

    nushell = let
      source = pkgs.srcOnly config.programs.nushell.package;
      gpgEnv = with config.services.gpg-agent;
        lib.optionalString (enable && enableSshSupport) ''
          if not ("SSH_CONNECTION" in $env) {
            $env.GPG_TTY = (tty)
            $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
          }
        '';
    in {
      enable = true;
      envFile.text = ''
        source ${source}/crates/nu-utils/src/sample_config/default_env.nu
        ${gpgEnv}
      '';
      configFile.text = ''
        source ${source}/crates/nu-utils/src/sample_config/default_config.nu
        $env.config.show_banner = false
      '';
      environmentVariables = config.home.sessionVariables;
    };

    starship = {
      enable = true;
      settings = {
        add_newline = false;
        scan_timeout = 10;
        character = {
          success_symbol = "[➜](bold green) ";
          error_symbol = "[✗](bold red) ";
        };
        cmd_duration = { min_time = 500; };
        directory = { truncation_length = 8; };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    tmux = {
      enable = true;
      escapeTime = 300;
      mouse = true;
      newSession = true;
      secureSocket = false;
      terminal = "screen-256color";

      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10' # minutes
          '';
        }
        # { plugin = fpp; }
        # { plugin = tmux-fzf; }
        # { plugin = yank; }
      ];
    };
  };
}
