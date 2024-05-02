{
  description = "My NixOS and home-manager configurations";

  inputs = {
    # most flake inputs are indirectly referenced,
    # so they're fetched from the local registry;

    # deduplication;
    devshell.inputs.flake-utils.follows = "flake-utils";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-utils.inputs.systems.follows = "systems";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix.inputs.flake-compat.follows = "flake-compat";
    nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # avoid recursive inputs rendering;
    nix-registry.flake = false;
    secrets.flake = false;
  };

  outputs = inputs @ {
    devshell,
    disko,
    flake-compat,
    flake-parts,
    flake-utils,
    home-manager,
    impermanence,
    nix,
    nixos-hardware,
    nixpkgs,
    sops-nix,
    systems,
    treefmt-nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [devshell.flakeModule treefmt-nix.flakeModule];

      flake = {lib, ...}: {
        homeConfigurations = import ./home-manager {inherit inputs lib;};
        nixosConfigurations = import ./nixos/hosts {inherit inputs lib;};
      };

      perSystem = {
        inputs',
        pkgs,
        ...
      }: {
        devshells.default = {
          packages = with pkgs; [
            age
            curl
            gitMinimal
            gnupg
            inputs'.disko.packages.disko
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
              name = "GNUPGHOME";
              eval = "$(printenv GNUPGHOME || find ~/.gnupg -maxdepth 0 || mktemp -d)";
            }
            {
              name = "GPG_TTY";
              eval = "$(tty)";
            }
            {
              name = "NIX_CONFIG";
              value = "extra-experimental-features = flakes nix-command repl-flake";
            }
            {
              name = "SSH_AUTH_SOCK";
              eval = "$(gpgconf --list-dirs agent-ssh-socket)";
            }
          ];
        };

        treefmt.config = {
          # programs.alejandra.enable = true;
          programs.nixfmt.enable = true;
          programs.prettier.enable = true;
          projectRootFile = "flake.nix";
          settings.formatter = {
            prettier.includes = ["*.lock"];
            nixfmt.excludes = ["flake.nix"];
            # TODO: use alejandra for flake.nix;
          };
        };
      };

      systems = import systems;
    };
}
