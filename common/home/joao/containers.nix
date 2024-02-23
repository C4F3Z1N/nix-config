{ pkgs, ... }: {
  home.packages = with pkgs; [ docker-compose kubectl lxc podman ];
}
