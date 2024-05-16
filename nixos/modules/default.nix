{
  imports = [
    # the list below contains the "global" config;
    ./autoUpgrade.nix
    ./containers.nix
    ./fonts.nix
    ./nix.nix
    ./nixpkgs.nix
    ./openssh.nix
    ./sops.nix
    ./sshServe.nix
  ];
}
