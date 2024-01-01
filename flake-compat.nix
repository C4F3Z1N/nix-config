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

  flake-compat = fetchNode (if lock.nodes ? flake-compat then
    lock.nodes.flake-compat.locked
  else {
    type = "tarball";
    url =
      "https://github.com/edolstra/flake-compat/archive/refs/tags/v1.0.1.tar.gz";
    narHash = "0m9grvfsbwmvgwaxvdzv6cmyvjnlww004gfxjvcl806ndqaxzy4j";
  });
in import flake-compat { inherit src; }
