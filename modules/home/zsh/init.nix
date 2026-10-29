{
  lib,
  pkgs,
  scriptsDir,
  ...
}:
{
  home.packages = [
    pkgs.zsh-completions
    pkgs.zsh-fzf-tab
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
  ];

  # Run after Home Manager's shell integrations. List order controls these stages.
  programs.zsh.initContent = lib.mkOrder 2000 (
    lib.concatStringsSep "\n\n" [
      ''
        # Shell behavior, completion preferences and command colors.
        source ${scriptsDir}/config/config_zsh_nix.sh
        source ${scriptsDir}/config/color_output.sh
      ''
      ''
        # Starship must follow the cursor-mode ZLE hooks to track vi mode.
        eval "$(starship init zsh)"
        source ${scriptsDir}/config/widgets.zsh
      ''
      ''
        # fzf-tab reads the completion preferences and FZF_DEFAULT_OPTS above.
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      ''
      ''
        source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
      ''
      ''
        # Syntax highlighting must see all widget definitions and wrappers.
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      ''
    ]
  );
}
