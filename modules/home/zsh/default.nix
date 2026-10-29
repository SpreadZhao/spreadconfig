{
  config,
  lib,
  scriptsDir,
  ...
}:

{
  imports = [
    ./scripts.nix
    ./init.nix
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    defaultKeymap = "viins";
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      append = true;
      extended = true;
      findNoDups = true;
      share = true;
      save = 10000;
      size = 10000;
    };
    shellAliases = {
      cat = "bat";
      df = "duf";
      du = "dust";
      cd = "z";
      rm = "rm -Iv";
      ls = "eza --icons";
      ll = "eza -l --git --icons";
      la = "eza -la --git --icons";
      l = "eza -lah --git --icons";
      n = "nvim .";
      lg = "lazygit";
      c = "clear";
      wk = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}";
      sb = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}/SecondBrain";
      st = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}/SpreadStudy";
      lc = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}/SpreadStudy/Leetcode/LeetcodeCpp/ && n";
      shuffle = "mpv --shuffle --force-window --autofit-smaller=800x500 .";
      q = "exit";
      ca = "${scriptsDir}/util/camera.sh";
      cdgvfs = "cd /run/user/$(id -u)/gvfs";
      se = "SUDO_EDITOR=${lib.getExe config.programs.nixvim.build.package} sudoedit";
      sf = "cd ~/workspaces/spreadconfig";
      mv = "mv -iv";
      cp = "cp -iv";
      mkdir = "mkdir -v";
      onefetch = "onefetch -T programming markup prose data";
      lf = "lfcd";
      ff = "${scriptsDir}/util/start_floating_foot.sh";
      ts = "gio trash";
      rsync = "rsync --progress";
    };
    shellGlobalAliases = { };
  };
}
