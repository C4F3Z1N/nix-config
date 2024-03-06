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
        init = { defaultBranch = "main"; };
        push = { autoSetupRemote = true; };
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
