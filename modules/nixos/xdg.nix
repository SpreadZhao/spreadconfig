{ ... }:

{
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  # Make system desktop entries and portal definitions visible to Home Manager.
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
