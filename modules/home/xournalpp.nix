{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.xournalpp ];

  xdg.configFile = {
    "xournalpp/plugins/LaserPointerShortcut/plugin.ini".text = ''
      [about]
      author=SpreadZhao
      description=Adds a keyboard shortcut for the built-in laser pointer.
      version=1.0.0

      [default]
      enabled=true

      [plugin]
      mainfile=main.lua
    '';

    "xournalpp/plugins/LaserPointerShortcut/main.lua".text = ''
      function initUi()
        app.registerUi({
          menu = "Laser pointer",
          callback = "selectLaserPointer",
          accelerator = "XF86Tools",
        })
      end

      function selectLaserPointer()
        app.changeActionState("select-tool", app.C.Tool_laserPointerPen)
      end
    '';
  };

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "application/x-xoj"
    "application/x-xojpp"
    "application/x-xopp"
    "application/x-xopt"
  ] (_: "com.github.xournalpp.xournalpp.desktop");
}
