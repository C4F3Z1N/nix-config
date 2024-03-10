{ pkgs, ... }: {
  home.packages = with pkgs; [ docker docker-compose kubectl lxc ];
}
