{ scriptsDir, ... }:

{
  programs.fzf = {
    enable = true;
    changeDirWidget = {
      command = "fd --type d";
      options = [
        "--preview 'eza --tree --color=always {} | head -200'"
      ];
    };
    defaultCommand = "fd --type f";
    fileWidget = {
      command = "fd --type f";
      options = [
        "--preview '${scriptsDir}/config/fzf_preview.sh {} \${FZF_PREVIEW_COLUMNS:-80} \${FZF_PREVIEW_LINES:-24}'"
      ];
    };
    historyWidget = {
      options = [
        "--sort"
        "--exact"
      ];
    };
  };
}
