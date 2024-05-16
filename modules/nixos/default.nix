{ lib }:
let moduleBaseName = path: lib.removeSuffix ".nix" (builtins.baseNameOf path);
in lib.pipe ./. [
  (lib.filesystem.listFilesRecursive)
  (builtins.filter (f: f != ./default.nix))
  (map (path: lib.nameValuePair (moduleBaseName path) (import path)))
  (builtins.listToAttrs)
]
