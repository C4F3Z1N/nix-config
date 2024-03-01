{ src ? ./. }:
let
  fetchNode = node@{ type, ... }:
    builtins.fetchTarball ({
      tarball = { narHash, url, ... }: {
        inherit url;
        sha256 = narHash;
      };
      github = { narHash, owner, repo, rev, ... }: {
        url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        sha256 = narHash;
      };
    }."${type}" node);

  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in import (fetchNode lock.nodes.flake-compat.locked) { inherit src; }
