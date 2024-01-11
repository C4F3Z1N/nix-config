{ inputs', pkgs }: {
  packages = with (pkgs // inputs'.disko.packages); [
    age
    curl
    disko
    gitMinimal
    gnupg
    nixos-anywhere
    nixos-install-tools
    nushell
    pinentry
    sops
    ssh-to-age
    ssh-to-pgp
    util-linux
  ];

  env = [
    {
      name = "NIX_CONFIG";
      value = "extra-experimental-features = flakes nix-command repl-flake";
    }
    {
      name = "GNUPGHOME";
      eval = "$(printenv GNUPGHOME || find ~/.gnupg -maxdepth 0 || mktemp -d)";
    }
  ];

  commands = [
    {
      name = "check";
      command = "nix flake check $@";
    }
    {
      help = "update flake lock file";
      name = "update";
      command = "nix flake update $@";
    }
    {
      name = "switch";
      command = "nixos-rebuild switch $@";
    }
  ];
}
