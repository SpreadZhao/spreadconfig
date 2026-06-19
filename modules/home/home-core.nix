{
  config,
  hostConfigSource,
  hostScriptSource,
  pkgs,
  installedJDKs,
  scriptsDir,
  ...
}:

{
  home = {
    username = "spreadzhao";
    homeDirectory = "/home/spreadzhao";
    stateVersion = "25.11";
    sessionVariables = {
      ANDROID_HOME = "${config.xdg.userDirs.extraConfig.LIB}/Android/Sdk";
      SCRIPT_HOME = scriptsDir;
      QT_QPA_PLATFORM = "wayland";
      QT_ENABLE_HIGHDPI_SCALING = "1";
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";
      TERMINAL = "foot";
      TERM = "foot";
    };
    shell.enableShellIntegration = true;
    sessionPath = [
      "$SCRIPT_HOME/niri/bin"
      "$SCRIPT_HOME/util/bin"
      "$SCRIPT_HOME/nix"
      "$ANDROID_HOME/platform-tools"
      "$HOME/.local/bin"
      "${config.xdg.userDirs.extraConfig.LIB}/jdks/bin"
    ];
    file = {
      "${scriptsDir}".source = hostScriptSource "";
      ".ideavimrc".source = hostConfigSource "Jetbrains/.ideavimrc";
    }
    // (builtins.listToAttrs (
      map (jdk: {
        name = "${config.xdg.userDirs.extraConfig.LIB}/jdks/${jdk.version}";
        value = {
          source = jdk;
        };
      }) installedJDKs
    ));
    pointerCursor = {
      enable = true;
      name = "Adwaita";
      size = 36;
      package = pkgs.adwaita-icon-theme;
      gtk.enable = true;
      x11.enable = true;
      dotIcons.enable = true;
      hyprcursor = {
        enable = false;
        size = 36;
      };
    };
  };
}
