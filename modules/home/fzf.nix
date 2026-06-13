{ scriptsDir, ... }:

{
  programs.fzf = {
    enable = true;
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
    ];
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f";
    fileWidgetOptions = [
      "--preview '${scriptsDir}/config/fzf_preview.sh {} \${FZF_PREVIEW_COLUMNS:-80} \${FZF_PREVIEW_LINES:-24}'"
    ];
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };
}
