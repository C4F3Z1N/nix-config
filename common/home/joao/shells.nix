{ config, lib, pkgs, ... }: {
  programs = {
    bash.enable = true;

    nushell = let
      defaultFromSrc = type:
        "${pkgs.nushell.src}/crates/nu-utils/src/sample_config/default_${type}.nu";
    in {
      enable = true;
      envFile.text = (builtins.readFile (defaultFromSrc "env"))
        + (lib.optionalString (builtins.all (value: value) [
          config.services.gpg-agent.enable
          config.services.gpg-agent.enableSshSupport
        ]) ''
          $env.GPG_TTY = (tty)
          $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
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

          $env.config = $current
        '');
    };

    carapace = {
      enable = true;
      enableNushellIntegration = false; # it's not working well;
    };

    starship.enable = true;

    git = {
      enable = true;
      package = pkgs.gitMinimal;
    };
  };
}
