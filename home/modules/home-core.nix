{
  config,
  pkgs,
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
      TERMINAL = "foot";
      TERM = "foot";
      http_proxy = "http://127.0.0.1:7897";
      https_proxy = "http://127.0.0.1:7897";
      ftp_proxy = "http://127.0.0.1:7897";
      rsync_proxy = "http://127.0.0.1:7897";
      no_proxy = "localhost,127.0.0.1,localaddress,.localdomain.com";
      HTTP_PROXY = "http://127.0.0.1:7897";
      HTTPS_PROXY = "http://127.0.0.1:7897";
    };
    shell.enableShellIntegration = true;
    sessionPath = [
      "$SCRIPT_HOME/niri/bin"
      "$SCRIPT_HOME/util/bin"
      "$SCRIPT_HOME/nix"
      "$HOME/.local/bin"
    ];
    file = {
      "${scriptsDir}".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/scripts";
      ".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/Jetbrains/.ideavimrc";
    };
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
