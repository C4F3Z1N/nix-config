{ lib, osConfig, pkgs, ... }: {
  home.packages = with osConfig.virtualisation; [
    (lib.mkIf docker.enable docker.package)
    (lib.mkIf incus.enable incus.lxcPackage)
    (lib.mkIf podman.enable podman.package)
    pkgs.kubectl
  ];
}
