{ pkgs, ... }: {
  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox-esr;
    };

    chromium.enable = true;
  };
}