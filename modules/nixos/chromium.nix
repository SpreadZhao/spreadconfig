{ lib, pkgs, ... }:

let
  quickmarksPath = "/home/spreadzhao/.password-store/qutebrowser/qutebrowser_quickmarks";
in
{
  programs.chromium = {
    enable = true;
    extensions = [ "mmlmfjhmonkocbjadbfplnigmagldckm" ];
    extraOptsRecommended.BookmarkBarEnabled = true;
    initialPrefs.vertical_tabs.enabled = true;
  };

  # Read personal bookmarks only at activation, never during evaluation/build.
  # A new host can activate gh credentials before cloning the private repository.
  # The converter writes atomically, preserving the last policy on failure.
  system.activationScripts.chromiumBookmarks = {
    deps = [ "etc" ];
    text = ''
      if [ -f ${lib.escapeShellArg quickmarksPath} ]; then
        if ! ${pkgs.python3}/bin/python3 ${./chromium-bookmarks.py} \
          ${lib.escapeShellArg quickmarksPath} ${lib.escapeShellArg "/etc/chromium/policies/managed/qutebrowser-bookmarks.json"}; then
          echo "Warning: Chromium bookmark refresh failed; keeping the previous policy." >&2
        fi
      fi
    '';
  };
}
