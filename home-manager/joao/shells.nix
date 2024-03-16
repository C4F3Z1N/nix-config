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
      nixEnv = osConfig.environment.variables
        // osConfig.environment.sessionVariables
        // config.home.sessionVariables;
    in {
      enable = true;
      envFile.text = ''
        source ${source}/crates/nu-utils/src/sample_config/default_env.nu
        mut nixEnv = ('${builtins.toJSON nixEnv}' | from json)
        use std assert
        for i in ($nixEnv | transpose key value) {
          if ('$' in $i.value) {
            let eval = do { ^sh -c $"printf ($i.value)" } | complete
            assert ($eval.exit_code == 0)
            $nixEnv = ($nixEnv | update $i.key $eval.stdout)
          }
        }
        load-env $nixEnv
        ${gpgEnv}
      '';
      configFile.text = ''
        source ${source}/crates/nu-utils/src/sample_config/default_config.nu
        $env.config.show_banner = false
      '';
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
      mouse = true;
      newSession = true;
      terminal = "screen-256color";
      # plugins = with pkgs.tmuxPlugins; [
      #   {
      #     plugin = resurrect;
      #     extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      #   }
      #   {
      #     plugin = continuum;
      #     extraConfig = ''
      #       set -g @continuum-restore 'on'
      #       set -g @continuum-save-interval '60' # minutes
      #     '';
      #   }
      #   { plugin = fpp; }
      #   { plugin = tmux-fzf; }
      #   { plugin = yank; }
      # ];
    };
  };

  services.pueue = {
    enable = true;
    settings = {
      shared.use_unix_socket = true;
      client.restart_in_place = true;
    };
  };
}
