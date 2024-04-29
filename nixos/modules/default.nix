{
  imports = [
    # the list below contains the "global" config;
    ./autoUpgrade.nix
    ./fonts.nix
    ./gpg-agent.nix
    ./nix.nix
    ./openssh.nix
    ./sops.nix
  ];
}
