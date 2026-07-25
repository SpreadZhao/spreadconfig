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

  dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;
}
