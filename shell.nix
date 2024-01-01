if builtins ? getFlake then
  (builtins.getFlake
    (builtins.toString ./.)).devShells.${builtins.currentSystem}.default
else
  (import ./flake-compat.nix { }).shellNix
