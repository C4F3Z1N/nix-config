{ lib, pkgs, ... }: {
  programs = {
    bash.enable = true;

    nushell = {
      enable = true;
      # TODO: add envFile and configFile;
    };

    git = {
      enable = true;
      package = pkgs.gitMinimal;
    };
  };
}
