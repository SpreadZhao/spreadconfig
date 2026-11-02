{ ... }:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    mouse = true;
    focusEvents = true;
    secureSocket = false;
    extraConfig = ''
      set -s extended-keys always
      set -s extended-keys-format csi-u
      set -as terminal-features 'foot*:extkeys,xterm*:extkeys'
      set -g allow-passthrough all
      set -g set-titles on
      set -g set-titles-string '#{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{pane_title},#W}'
      set -g window-status-separator ""
      set -g window-status-format ' #I:#{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{=/12/…:#{s/ \| .*//:pane_title}},#W} '
      set -g window-status-current-style 'bg=black,fg=brightgreen,bold'
      set -g window-status-current-format ' #I:#{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{=/12/…:#{s/ \| .*//:pane_title}},#W} '
      set -g status-right-length 80
      set -g status-right ' #{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{pane_title},#W} '
      set-hook -g pane-title-changed 'refresh-client -S'
      unbind -T copy-mode MouseDragEnd1Pane
      unbind -T copy-mode-vi MouseDragEnd1Pane
    '';
  };
}
