{ pkgs, ... }: {
  home.packages = with pkgs;
    [
      (google-cloud-sdk.withExtraComponents
        [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    ];

  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    extraConfig = {
      init = { defaultBranch = "main"; };
      push = { autoSetupRemote = true; };
    };
  };
}
