{
  lib,
  config,
  pkgs,
  installedJDKs,
  scriptsDir,
  spreadconfigDir,
  ...
}:

{
  home = {
    username = "spreadzhao";
    homeDirectory = "/home/spreadzhao";
    stateVersion = "25.11";
    sessionVariables = {
      SCRIPT_HOME = scriptsDir;
      QT_QPA_PLATFORM = "wayland";
      QT_ENABLE_HIGHDPI_SCALING = "1";
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";
      TERMINAL = "kitty";
      TERM = "kitty";
      VOLCENGINE_API_KEY = "${lib.strings.trim (builtins.readFile ../../secrets/volcengine_api_key)}";
    };
    shell.enableShellIntegration = true;
    sessionPath = [
      "$SCRIPT_HOME/niri/bin"
      "$SCRIPT_HOME/util/bin"
      "$SCRIPT_HOME/nix"
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "$HOME/Android/Sdk/platform-tools"
      "$HOME/Lib/jdks/bin"
      "$HOME/.npm/bin"
    ];
    file = {
      "${scriptsDir}".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/scripts";
      ".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/Jetbrains/.ideavimrc";
    }
    # jdk
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
