{
  description = "monkeytype custom theme share url from vity, or any base16 / base24 scheme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vity-base24 = {
      url = "github:Alexdelia/vity-base24";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      git-hooks,
      vity-base24,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        generate = pkgs.writeShellApplication {
          name = "generate";
          runtimeInputs = with pkgs; [
            yq-go
            jq
          ];
          text = builtins.readFile ./generate.sh;
        };

        vityUrl = pkgs.runCommand "vity-monkeytype-url" { } ''
          ${lib.getExe generate} ${vity-base24}/vity.yaml > $out
        '';

        vityPalette = pkgs.runCommand "vity-monkeytype-palette" { } ''
          mkdir $out
          cd $out
          ${lib.getExe generate} --palette palette ${vity-base24}/vity.yaml > table.html
        '';

        printVityUrl = pkgs.writeShellApplication {
          name = "vity-monkeytype";
          text = "cat ${vityUrl}";
        };

        updateGenerated = pkgs.writeShellApplication {
          name = "update-generated";
          runtimeInputs = with pkgs; [
            coreutils
            gnused
            gawk
          ];
          runtimeEnv = {
            VITY_URL = vityUrl;
            VITY_PALETTE = vityPalette;
          };
          text = builtins.readFile ./nix/update-generated.bash;
        };

        hook = import ./nix/hook {
          inherit
            git-hooks
            system
            pkgs
            updateGenerated
            ;
          src = ./.;
        };

        mkApp = program: description: {
          type = "app";
          program = lib.getExe program;
          meta = { inherit description; };
        };
      in
      {
        packages = {
          default = vityUrl;
          palette = vityPalette;
          inherit generate;
          update-generated = updateGenerated;
        };

        apps = {
          default = mkApp printVityUrl "print vity monkeytype share url";
          generate = mkApp generate "print monkeytype share url, or palette swatches and table, of any base16 / base24 scheme";
          update-generated = mkApp updateGenerated "write current vity share url and palette table into README.md, swatches into palette/";
        };

        checks = {
          pre-commit = hook;
        }
        // import ./nix/test { inherit pkgs generate; };

        devShells.default = pkgs.mkShell {
          inherit (hook) shellHook;
          packages =
            with pkgs;
            [
              bash
              yq-go
              jq

              nixfmt
              shfmt
              shellcheck
            ]
            ++ hook.enabledPackages;
        };
      }
    );
}
