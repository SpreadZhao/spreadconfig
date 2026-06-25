{
  inputs,
  pkgs,
  ...
}:

let
  claudeCodePackage = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ claudeCodePackage ];
}
