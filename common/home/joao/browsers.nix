{ config, lib, pkgs, ... }: {
  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      profiles = {
        "${config.home.username}" = {
          isDefault = true;
          search = {
            default = "ddg"; # custom DuckDuckGo;
            engines = let updateInterval = 24 * 60 * 60 * 1000; # every day
            in {
              ddg = {
                inherit updateInterval;
                urls = [{
                  template = "https://ddg.gg";
                  params = lib.mapAttrsToList lib.nameValuePair {
                    kae = "d"; # dark theme;
                    kh = 1;
                    q = "{searchTerms}";
                  };
                }];
                iconUpdateURL = "https://ddg.gg/favicon.ico";
              };

              "Nix Packages" = {
                inherit updateInterval;
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = lib.mapAttrsToList lib.nameValuePair {
                    type = "packages";
                    query = "{searchTerms}";
                  };
                }];
                iconUpdateURL = "https://nixos.org/favicon.png";
                definedAliases = [ "@nixpkgs" "@np" ];
              };

              "home-manager options" = {
                urls = [{
                  template =
                    "https://mipmip.github.io/home-manager-option-search/?query={searchTerms}";
                }];
                icon =
                  "${pkgs.gnome.adwaita-icon-theme}/share/icons/Adwaita/scalable/places/user-home.svg";
                definedAliases = [ "@home-manager" "@hm" ];
              };

              "Amazon".metaData.hidden = true;
              "Bing".metaData.hidden = true;
              "DuckDuckGo".metaData.hidden = true;
              "Google".metaData.hidden = true;
            };
          };
        };
      };
    };

    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [ "--incognito" ];
    };
  };
}
