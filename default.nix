if builtins ? getFlake then
  builtins.getFlake (builtins.toString ./.)
else
  (import ./flake-compat.nix { }).defaultNix
