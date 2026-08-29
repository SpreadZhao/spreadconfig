{ pkgs, ... }:

let
  quickmarksPath = "/home/spreadzhao/.password-store/qutebrowser/qutebrowser_quickmarks";
  policyPath = "/etc/chromium/policies/managed/qutebrowser-bookmarks.json";
  syncBookmarks = pkgs.writeShellApplication {
    name = "sync-qutebrowser-chromium-bookmarks";
    text = ''
      exec ${pkgs.python3}/bin/python3 ${./chromium-bookmarks.py} "$@"
    '';
  };
in
{
  programs.chromium = {
    enable = true;
    extraOptsRecommended.BookmarkBarEnabled = true;
    initialPrefs.vertical_tabs.enabled = true;
  };

  systemd.services.chromium-qutebrowser-bookmarks = {
    description = "Synchronize qutebrowser quickmarks to Chromium";
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = quickmarksPath;
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      UMask = "0022";
      ExecStart = "${syncBookmarks}/bin/sync-qutebrowser-chromium-bookmarks ${quickmarksPath} ${policyPath}";
    };
  };

  systemd.paths.chromium-qutebrowser-bookmarks = {
    description = "Watch qutebrowser quickmarks for Chromium synchronization";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = quickmarksPath;
      PathModified = quickmarksPath;
      Unit = "chromium-qutebrowser-bookmarks.service";
    };
  };
}
