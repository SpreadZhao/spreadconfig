{ inputs, pkgs, ... }:

let
  hermesPackages = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # home.packages = [
  #   hermesPackages.default
  #   hermesPackages.desktop
  # ];
  #
  # xdg.desktopEntries.hermes-desktop = {
  #   name = "Hermes Desktop";
  #   comment = "Native desktop shell for Hermes Agent";
  #   exec = "${hermesPackages.desktop}/bin/hermes-desktop";
  #   icon = "utilities-terminal";
  #   categories = [
  #     "Development"
  #     "Utility"
  #   ];
  #   terminal = false;
  #   type = "Application";
  # };
}
