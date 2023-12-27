(builtins.getFlake
  (builtins.toString ./.)).devShells.${builtins.currentSystem}.default
