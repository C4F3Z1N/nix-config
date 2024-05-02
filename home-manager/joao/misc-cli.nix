{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    home-manager
    htop
    rclone
  ];

  programs = {
    bat.enable = true;
    ripgrep.enable = true;

    git = {
      enable = true;
      package = pkgs.gitMinimal;
      extraConfig = {
        commit.gpgsign = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [
        editorconfig-nvim
        # nvim-treesitter
        plenary-nvim
        telescope-nvim
      ];
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
