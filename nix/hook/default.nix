{
  git-hooks,
  system,
  pkgs,
  src,
  updateGenerated,
  policy,
}:
let
  policyHook = name: files: {
    enable = true;
    inherit name files;
    entry = pkgs.lib.getExe policy.${name};
  };
in
git-hooks.lib.${system}.run {
  inherit src;
  hooks = {
    nixfmt.enable = true;
    shfmt.enable = true;
    typos.enable = true;

    shellcheck = {
      enable = true;
      files = "\\.(sh|bash)$";
      args = [ "--shell=bash" ];
    };

    no-comment = policyHook "no-comment" "\\.(nix|sh|bash|ya?ml)$";
    ascii-only = policyHook "ascii-only" "" // {
      types = [ "text" ];
    };

    generated = {
      enable = true;
      name = "generated";
      description = "write current vity share url and palette table into README.md, swatches into palette/";
      entry = "${pkgs.lib.getExe updateGenerated}";
      always_run = true;
      pass_filenames = false;
    };

    deadnix.enable = true;
    statix.enable = true;
  };
}
