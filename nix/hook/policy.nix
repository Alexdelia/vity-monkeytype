{ pkgs }:
pkgs.lib.genAttrs [ "no-comment" "ascii-only" ] (
  name:
  pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [ pkgs.ripgrep ];
    text = builtins.readFile ./${name}.bash;
  }
)
