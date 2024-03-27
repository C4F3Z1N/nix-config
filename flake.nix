{
  inputs = {
    nix-registry.url = "github:c4f3z1n/nix-registry";

    flake-compat.url = "flake:flake-compat";
    impermanence.url = "flake:impermanence";
    nixos-hardware.url = "flake:nixos-hardware";
    nixpkgs.url = "flake:nixpkgs";

    devshell = {
      url = "flake:devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "flake:disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "flake:flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "flake:home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "flake:sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "flake:treefmt-nix";
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
