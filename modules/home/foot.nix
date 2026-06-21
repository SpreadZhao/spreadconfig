{
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
  scriptsDir,
  ...
}:

{
  programs.foot = {
    enable = true;
    server.enable = true;
  };

  xdg.desktopEntries.foot_new_tab = {
    name = "Foot New Tab";
    type = "Application";
    exec = "${scriptsDir}/niri/foot_new_tab.sh";
    icon = "";
    terminal = false;
  };

  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=${fontFamilies.mono}:size=${toString fontSizes.foot}, ${fontFamilies.nerdMono}:size=${toString fontSizes.foot}
    font-size-adjustment=0.5
    bold-text-in-bright=yes

    [bell]
    system=yes
    urgent=yes
    notify=yes

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
    inhibit-when-focused=yes

    [key-bindings]
    unicode-input=none
    scrollback-up-half-page=Control+u
    scrollback-down-half-page=Control+d
    scrollback-home=Control+Home
    scrollback-end=Control+End
    search-start=Control+slash
    font-increase=Control+plus Control+equal Control+KP_Add
    font-decrease=Control+minus Control+KP_Subtract
    font-reset=Control+0 Control+KP_0

    [search-bindings]
    find-prev=Control+Shift+p
    find-next=Control+Shift+n
  '';
}
