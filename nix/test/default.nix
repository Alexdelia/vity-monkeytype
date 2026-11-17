{
  pkgs,
  generate,
  updateGenerated,
}:
let
  inherit (pkgs) lib;

  mkTest =
    name:
    let
      test = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [
          generate
          updateGenerated
          pkgs.jq
          pkgs.uutils-coreutils-noprefix
        ];
        text = builtins.readFile ./${name}.bash;
      };
      fixture = ./${name}.yaml;
    in
    pkgs.runCommand name { } ''
      ${lib.getExe test} ${lib.optionalString (builtins.pathExists fixture) "${fixture}"}
      touch $out
    '';

  names = map (lib.removeSuffix ".bash") (
    lib.filter (lib.hasSuffix ".bash") (lib.attrNames (builtins.readDir ./.))
  );
in
lib.genAttrs names mkTest
