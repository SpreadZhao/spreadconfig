{
  appEntries,
  appSource,
  pkgs,
  projDir,
  repoLink,
  scriptsDir,
  theme_background,
  theme_bright_background,
  theme_bright_blue,
  theme_bright_red,
  theme_bright_white,
  theme_bright_yellow,
  theme_white,
  ...
}:

{
  spreadconfig.scriptFiles = appEntries "tmux" "scripts";

  xdg.configFile."tmux/scrollback.lua".source = repoLink (appSource "tmux" "files/scrollback.lua");

  xdg.desktopEntries.tmux_attach = {
    name = "Tmux Attach";
    comment = "Attach to an unattached tmux session";
    exec = "${scriptsDir}/util/tmux_attach.sh";
    type = "Application";
    icon = "";
    terminal = false;
  };

  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    keyMode = "vi";
    terminal = "tmux-256color";
    historyLimit = 50000;
    mouse = true;
    focusEvents = true;
    secureSocket = false;
    plugins = [
      pkgs.tmuxPlugins.vim-tmux-navigator
      {
        plugin = pkgs.tmuxPlugins.prefix-highlight;
        extraConfig = ''
          set -g @prefix_highlight_fg '#${theme_background}'
          set -g @prefix_highlight_bg '#${theme_bright_blue}'
          set -g @prefix_highlight_show_copy_mode 'on'
          set -g @prefix_highlight_copy_mode_attr 'fg=#${theme_background},bg=#${theme_bright_yellow},bold'
          set -g @prefix_highlight_show_sync_mode 'on'
          set -g @prefix_highlight_sync_mode_attr 'fg=#${theme_bright_white},bg=#${theme_bright_red},bold'
          set -g status-right-length 80
          set -g status-right '#{prefix_highlight} #{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{pane_title},#W} '
        '';
      }
    ];
    extraConfig = ''
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      set -s extended-keys always
      set -s extended-keys-format csi-u
      set -as terminal-features 'foot*:extkeys,xterm*:extkeys'
      set -g allow-passthrough all
      set -g set-titles on
      set -g set-titles-string '#{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{pane_title},#W}'
      set -g popup-style default
      set -g status-style 'bg=#${theme_background},fg=#${theme_white}'
      set -g window-status-separator ""
      set -g window-status-style 'bg=#${theme_background},fg=#${theme_white}'
      set -g @win_raw_len '#{e|-:#{e|/:#{e|-:#{e|-:#{window_width},#{w;T;=/#{status-left-length}:status-left}},#{e|+:#{w;T;=/#{status-right-length}:status-right},15}},#{session_windows}},5}'
      set -g @win_max_len '#{?#{e|>:#{E:@win_raw_len},20},20,#{?#{e|<:#{E:@win_raw_len},4},4,#{E:@win_raw_len}}}'
      set -g window-status-format ' #I:#{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{=/#{E:@win_max_len}/…:#{s/ \| .*//:pane_title}},#{=/#{E:@win_max_len}/…:window_name}} '
      set -g window-status-current-style 'bg=#${theme_bright_background},fg=#${theme_bright_yellow},bold'
      set -g window-status-current-format ' #I:#{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{=/20/…:#{s/ \| .*//:pane_title}},#{=/20/…:window_name}} '
      set -g window-status-bell-style 'bg=#${theme_bright_red},fg=#${theme_bright_white}'
      set-hook -g pane-title-changed 'refresh-client -S'
      set-hook -g pane-mode-changed 'if -F "#{pane_in_mode}" "set -p cursor-style block" "set -p cursor-style default"'
      bind Space run-shell -C 'display-popup -x P -y P -w #{pane_width} -h #{pane_height} -B -E -e "TMUX_SCROLLBACK_PANE=#{pane_id}" -e "TMUX_SCROLLBACK_CX=#{cursor_x}" -e "TMUX_SCROLLBACK_CY=#{cursor_y}" -e "TMUX_SCROLLBACK_PH=#{pane_height}" nvim -S ${projDir}/${appSource "tmux" "files/scrollback.lua"}'
      bind -T copy-mode-vi v { send-keys -X rectangle-off; send-keys -X begin-selection }
      bind -T copy-mode-vi V send-keys -X select-line
      bind -T copy-mode-vi C-v { if -F "#{selection_present}" { send-keys -X rectangle-toggle } { send-keys -X rectangle-on; send-keys -X begin-selection } }
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
      unbind -T copy-mode MouseDragEnd1Pane
      unbind -T copy-mode-vi MouseDragEnd1Pane
    '';
  };
}
