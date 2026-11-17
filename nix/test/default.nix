{
  pkgs,
  generate,
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
          pkgs.jq
          pkgs.coreutils
        ];
        text = builtins.readFile ./${name}.bash;
      };
    in
    pkgs.runCommand name { } ''
      ${lib.getExe test} ${./${name}.yaml}
      touch $out
    '';

  names = map (lib.removeSuffix ".bash") (
    lib.filter (lib.hasSuffix ".bash") (lib.attrNames (builtins.readDir ./.))
  );
in
lib.genAttrs names mkTest
