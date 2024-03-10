{ config, lib, pkgs, ... }: {
  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [ "--incognito" ];
    };

    firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      profiles = {
        "${config.home.username}" = {
          isDefault = true;
          search = {
            force = true;
            default = "DuckDuckGo";
            engines = {
              "Nix Packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = lib.mapAttrsToList lib.nameValuePair {
                    type = "packages";
                    query = "{searchTerms}";
                  };
                }];
                icon =
                  "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
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
            } // lib.genAttrs [ "Amazon" "Bing" "Google" ]
              (_: { metaData.hidden = true; });
          };
        };
      };
    };

    qutebrowser = {
      enable = true;
      loadAutoconfig = true;
      settings = {
        "editor.command" = [ "xdg-open" "{file}" ];
        "fonts.default_family" = "Ubuntu";
        "qt.highdpi" = true;
        "tabs.show" = "multiple";
      };
      extraConfig = ''
        c.tabs.padding = {"bottom": 10, "left": 10, "right": 10, "top": 10}
      '';
    };
  };
}