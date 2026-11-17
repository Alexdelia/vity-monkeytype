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

        printVityUrl = pkgs.writeShellApplication {
          name = "vity-monkeytype";
          text = "cat ${vityUrl}";
        };

        updateReadme = pkgs.writeShellApplication {
          name = "update-readme";
          runtimeInputs = [ pkgs.gnused ];
          text = ''
            sed -i -E 's|https://monkeytype\.com\?customTheme=[A-Za-z0-9%]*|'"$(cat ${vityUrl})"'|g' README.md
          '';
        };

        hook = import ./nix/hook {
          inherit
            git-hooks
            system
            pkgs
            updateReadme
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
          inherit generate;
          update-readme = updateReadme;
        };

        apps = {
          default = mkApp printVityUrl "print vity monkeytype share url";
          generate = mkApp generate "print monkeytype share url of any base16 / base24 scheme";
          update-readme = mkApp updateReadme "write current vity share url into README.md";
        };

        checks.pre-commit = hook;

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
