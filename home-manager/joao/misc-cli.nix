{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    (inputs.home-manager.packages."${system}".home-manager)
  ];

  programs = {
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
