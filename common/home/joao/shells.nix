{ lib, pkgs, ... }: {
  programs = {
    bash.enable = true;

    nushell = let
      defaultFromSrc = type:
        "${pkgs.nushell.src}/crates/nu-utils/src/sample_config/default_${type}.nu";
    in {
      enable = true;
      envFile.text = (builtins.readFile (defaultFromSrc "env")) + "";
      configFile.text = (builtins.readFile (defaultFromSrc "config")) + "";
    };

    git = {
      enable = true;
      package = pkgs.gitMinimal;
    };
  };
}
