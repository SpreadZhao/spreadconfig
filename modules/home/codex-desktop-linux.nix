{
  inputs,
  pkgs,
  ...
}:

let
  codexPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = codexPackage;
  };
}
