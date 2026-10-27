{ ... }:

{
  systemd.services.greetd.environment = {
    XDG_CURRENT_DESKTOP = "dwl";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "dwl";
  };
}
