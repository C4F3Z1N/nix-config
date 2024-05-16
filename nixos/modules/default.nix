{
  imports = [
    # the list below contains the "global" config;
    ../../modules/nixos/services/host-gpg-agent.nix
    ./autoUpgrade.nix
    ./containers.nix
    ./fonts.nix
    ./nix.nix
    ./nixpkgs.nix
    ./openssh.nix
    ./sops.nix
  ];
}
