{ config, lib, osConfig, pkgs, ... }:
let headless = builtins.elem "headless" osConfig.system.nixos.tags;
in {
  programs = {
    bash.enable = true;

    nushell = let
      src = pkgs.srcOnly config.programs.nushell.package;
      defaultFromSrc = type:
        "${src}/crates/nu-utils/src/sample_config/default_${type}.nu";
    in {
      enable = true;
      envFile.text = (builtins.readFile (defaultFromSrc "env"))
        + (lib.optionalString (builtins.all (value: value) [
          config.services.gpg-agent.enable
          config.services.gpg-agent.enableSshSupport
        ]) ''
          if not ("SSH_CONNECTION" in $env) {
            $env.GPG_TTY = (tty)
            $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
          }
        '');
      configFile.text = (builtins.readFile (defaultFromSrc "config"))
        + (lib.optionalString config.programs.carapace.enable ''
          def --env get-env [name] { $env | get $name }
          def --env set-env [name, value] { load-env { $name: $value } }
          def --env unset-env [name] { hide-env $name }

          let carapace_completer = {|spans|
            carapace $spans.0 nushell $spans | from json
          }

          mut current = (($env | default {} config).config | default {} completions)
          $current.completions = ($current.completions | default {} external)
          $current.completions.external = ($current.completions.external
            | default true enable
            | default $carapace_completer completer)
          $current.show_banner = false

          $env.config = $current
        '');
    };

    carapace = {
      enable = true;
      enableNushellIntegration = false; # it's not working well;
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

    tmux = {
      enable = true;
      mouse = true;
      newSession = true;
      terminal = "screen-256color";
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
          '';
        }
      ];
    };

    alacritty = {
      enable = !headless;
      settings = {
        import = [ "${pkgs.alacritty-theme}/monokai_charcoal.yaml" ];
        live_config_reload = true;
        scrolling = {
          history = 10000;
          multiplier = 5;
        };
        shell = lib.mkIf config.programs.tmux.enable {
          program = lib.getExe config.programs.tmux.package;
          args = [ "attach" ];
        };
      };
    };
  };
}
