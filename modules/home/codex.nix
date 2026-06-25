{
  hostConfigSource,
  inputs,
  pkgs,
  ...
}:

let
  codexPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ codexPackage ];

  home.file.".codex/themes/spreadzhao.tmTheme".source =
    hostConfigSource "codex/themes/spreadzhao.tmTheme";
}
