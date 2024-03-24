{
  inputs = {
    nixpkgs.follows = "nixpkgs-stable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat.url = "github:edolstra/flake-compat";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-keys = {
      url = "https://github.com/c4f3z1n.keys";
      flake = false;
    };

    github-metadata = {
      url = "https://api.github.com/meta";
      flake = false;
    };
  };

  outputs = inputs@{ devshell, flake-parts, treefmt-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ devshell.flakeModule treefmt-nix.flakeModule ];

      flake = {
        inherit (import ./home-manager { inherit inputs; }) homeConfigurations;
        inherit (import ./nixos/hosts { inherit inputs; }) nixosConfigurations;
      };

      perSystem = { inputs', pkgs, ... }: {
        devshells.default = {
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
              name = "GNUPGHOME";
              eval =
                "$(printenv GNUPGHOME || find ~/.gnupg -maxdepth 0 || mktemp -d)";
            }
            {
              name = "GPG_TTY";
              eval = "$(tty)";
            }
            {
              name = "NIX_CONFIG";
              value =
                "extra-experimental-features = flakes nix-command repl-flake";
            }
            {
              name = "SSH_AUTH_SOCK";
              eval = "$(gpgconf --list-dirs agent-ssh-socket)";
            }
          ];
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.prettier.enable = true;
          settings.formatter.prettier.includes = [ "*.lock" ];
        };
      };

      systems = [ "aarch64-linux" "x86_64-linux" ];
    };
}
