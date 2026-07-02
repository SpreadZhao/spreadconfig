{
  config,
  lib,
  pkgs,
  scriptsDir,
  ...
}:

{
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
      ca = "mpv /dev/video0";
      cdgvfs = "cd /run/user/$(id -u)/gvfs";
      se = "sudo -E nvim";
      sf = "cd ~/workspaces/spreadconfig";
      mv = "mv -iv";
      cp = "cp -iv";
      mkdir = "mkdir -v";
      onefetch = "onefetch -T programming markup prose data";
      lf = "lfcd";
      ff = "${scriptsDir}/niri/start_floating_foot.sh";
      ts = "gio trash";
      rsync = "rsync --progress";
      slurp = "slurp -b #0e1117aa -c #f5e0dc";
      as = "agent-skills";
      wkc = "wk && codex resume";
    };
    shellGlobalAliases = { };
    initContent = lib.mkOrder 2000 ''
      source ${scriptsDir}/config/config_zsh_nix.sh
      source ${scriptsDir}/config/color_output.sh
      eval "$(starship init zsh)"

      lfcd () {
          # `command` is needed in case `lfcd` is aliased to `lf`
          cd "$(command lf -print-last-dir "$@")"
      }

      feh () {
          local explicit_theme=0
          local expecting_theme=0
          local has_directory=0
          local arg

          for arg in "$@"; do
              if (( expecting_theme )); then
                  expecting_theme=0
                  continue
              fi

              case "$arg" in
                  --theme|-T)
                      explicit_theme=1
                      expecting_theme=1
                      ;;
                  --theme=*|-T*)
                      explicit_theme=1
                      ;;
                  --)
                      ;;
                  -*)
                      ;;
                  *)
                      if [[ -d "$arg" ]]; then
                          has_directory=1
                      fi
                      ;;
              esac
          done

          if (( explicit_theme )); then
              command feh "$@"
          elif (( $# == 0 )); then
              command feh --theme gallery .
          elif (( has_directory )); then
              command feh --theme gallery "$@"
          else
              command feh --theme fit "$@"
          fi
      }

      function vi-yank-wlclip {
          zle vi-yank
          print -rn -- "$CUTBUFFER" | wl-copy
      }

      zle -N vi-yank-wlclip
      bindkey -M vicmd 'y' vi-yank-wlclip

      # plugins
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };
}
