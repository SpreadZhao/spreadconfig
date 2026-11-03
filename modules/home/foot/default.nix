{
  appEntries,
  theme_background,
  theme_red,
  theme_green,
  theme_yellow,
  theme_blue,
  theme_magenta,
  theme_cyan,
  theme_white,
  theme_bright_dark,
  theme_bright_blue,
  fontFamilies,
  fontSizes,
  ...
}:

{
  programs.foot = {
    enable = true;
    server.enable = true;
  };

  systemd.user.services.foot.Service = {
    # foot --server exits with 230 (-EPIPE) when the compositor closes WAYLAND_DISPLAY on shutdown.
    SuccessExitStatus = 230;
    TimeoutStopSec = 3;
  };

  spreadconfig.scriptFiles = appEntries "foot" "scripts";

  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=${fontFamilies.mono}:size=${toString fontSizes.foot}, ${fontFamilies.nerdMono}:size=${toString fontSizes.foot}
    font-size-adjustment=0.5
    bold-text-in-bright=yes
    resize-by-cells=no

    [bell]
    system=yes
    urgent=yes
    notify=no

    [scrollback]
    lines=1000
    multiplier=3.0
    indicator-position=relative

    [colors-dark]
    alpha=1.0
    alpha-mode=default
    foreground=ffffff
    background=000000
    cursor=171616 adaeac
    flash=7f7f00
    flash-alpha=0.5

    # ANSI 8 colors
    regular0=${theme_background}
    regular1=${theme_red}
    regular2=${theme_green}
    regular3=${theme_yellow}
    regular4=${theme_blue}
    regular5=${theme_magenta}
    regular6=${theme_cyan}
    regular7=${theme_white}

    # Bright variants
    bright0=${theme_bright_dark}
    bright1=ff6b6b
    bright2=b4cda8
    bright3=d7ba7d
    bright4=${theme_bright_blue}
    bright5=e49ad8
    bright6=5fe0c6
    bright7=ffffff

    selection-foreground=adaeac
    selection-background=264e77

    dim-blend-towards=black
    scrollback-indicator=171616 ${theme_bright_blue}
    search-box-no-match=171616 f44747
    search-box-match=adaeac 262626

    jump-labels=171616 e6e6aa
    urls=47a2ed

    [cursor]
    style=beam

    [desktop-notifications]
    command=notify-send --wait --app-name ${"$"}{app-id} --icon ${"$"}{app-id} --category ${"$"}{category} --urgency ${"$"}{urgency} --expire-time ${"$"}{expire-time} --hint STRING:image-path:${"$"}{icon} --hint BOOLEAN:suppress-sound:${"$"}{muted} --hint STRING:sound-name:${"$"}{sound-name} --replace-id ${"$"}{replace-id} ${"$"}{action-argument} --print-id -- ${"$"}{title} ${"$"}{body}
    command-action-argument=--action ${"$"}{action-name}=${"$"}{action-label}
    inhibit-when-focused=no

    [key-bindings]
    unicode-input=none
    scrollback-up-page=Control+Shift+Page_Up Control+Shift+KP_Page_Up
    scrollback-down-page=Control+Shift+Page_Down Control+Shift+KP_Page_Down
    scrollback-up-half-page=Shift+Page_Up Shift+KP_Page_Up
    scrollback-down-half-page=Shift+Page_Down Shift+KP_Page_Down
    scrollback-home=Shift+Home
    scrollback-end=Shift+End
    search-start=Control+Shift+f
    font-increase=Control+plus Control+equal Control+KP_Add
    font-decrease=Control+minus Control+KP_Subtract
    font-reset=Control+0 Control+KP_0
    pipe-scrollback=[sh -c "f=$(mktemp); cat > \"$f\"; footclient -T terminal-scrollback nvim -R \"$f\"; rm -f \"$f\""] Control+Shift+h

    [search-bindings]
    find-prev=Control+Shift+p
    find-next=Control+Shift+n
  '';

  home.sessionVariables = {
    TERMINAL = "foot";
    TERM = "foot";
  };
}
