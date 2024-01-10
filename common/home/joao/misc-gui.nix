{ lib, osConfig, pkgs, ... }: {
  home.packages = with pkgs; [ slack virt-manager vscode ];
}

