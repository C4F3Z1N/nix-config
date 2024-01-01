{ lib, pkgs, ... }: {
  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    docker
    docker-compose
    kubectl
    lxc
    slack
    vscode
  ];
}
