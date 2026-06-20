{ inputs, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = false;
      addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
          ];
        })
        inputs.textbridge.packages.${pkgs.system}.fcitx5-textbridge
      ];
      # settings = {
      #   inputMethod = {
      #     GroupOrder."0" = "Default";
      #     "Groups/0" = {
      #       Name = "Default";
      #       "Default Layout" = "us";
      #       DefaultIM = "rime";
      #     };
      #     "Groups/0/Items/0".Name = "keyboard-us";
      #     "Groups/0/Items/1".Name = "rime";
      #   };
      #   globalOptions = {
      #     Behavior = {
      #       ActiveByDefault = false;
      #       resetStateWhenFocusIn = "No";
      #       ShareInputState = "No";
      #       PreeditEnabledByDefault = true;
      #       ShowInputMethodInformation= true;
      #       showInputMethodInformationWhenFocusIn = false;
      #       CompactInputMethodInformation = true;
      #       ShowFirstInputMethodInformation= true;
      #       DefaultPageSize = 9;
      #       OverrideXkbOption = false;
      #       PreloadInputMethod = true;
      #       AllowInputMethodForPassword = false;
      #       ShowPreeditForPassword = false;
      #       AutoSavePeriod = 30;
      #     };
      #     Hotkey = {
      #       EnumerateWithTriggerKeys = true;
      #       EnumerateSkipFirst = false;
      #       ModifierOnlyKeyTimeout = 250;
      #     };
      #     "Hotkey/TriggerKeys" = {
      #       "0" = "Control+space";
      #       "1" = "Zenkaku_Hankaku";
      #       "2" = "Hangul";
      #     };
      #     "Hotkey/AltTriggerKeys" = {
      #       "0" = "Shift_L";
      #     };
      #     "Hotkey/PrevPage" = {
      #       "0" = "Up";
      #     };
      #     "Hotkey/NextPage" = {
      #       "0" = "Down";
      #     };
      #     "Hotkey/PrevCandidate" = {
      #       "0" = "Shift+Tab";
      #     };
      #     "Hotkey/NextCandidate" = {
      #       "0" = "Tab";
      #     };
      #     "Hotkey/TogglePreedit" = {
      #       "0" = "Control+Alt+P";
      #     };
      #   };
      #   addons = {
      #     classicui.globalSection = {
      #       "Vertical Candidate List" = false;
      #       WheelForPaging = true;
      #       Font = "Noto Sans 18";
      #       MenuFont = "Noto Sans 10";
      #       TrayFont = "Noto Sans 10";
      #       TrayOutlineColor = "#000000";
      #       TrayTextColor = "#ffffff";
      #       PreferTextIcon = true;
      #       ShowLayoutNameInIcon = true;
      #       UseInputMethodLanguageToDisplayText = true;
      #       Theme= "catppuccin-mocha-rosewater";
      #       DarkTheme = "catppuccin-mocha-rosewater";
      #       UseDarkTheme = false;
      #       UseAccentColor = false;
      #       PerScreenDPI = false;
      #       ForceWaylandDPI = 0;
      #       EnableFractionalScale = true;
      #     };
      #     keyboard = {
      #       globalSection = {
      #         PageSize = 9;
      #         EnableEmoji = true;
      #         EnableQuickPhraseEmoji = true;
      #         "Choose Modifier" = "Alt";
      #         EnableHintByDefault = false;
      #         UseNewComposeBehavior = true;
      #         EnableLongPress = false;
      #         # PrevCandidate = {
      #         #   "0" = "Shift+Tab";
      #         # };
      #         # NextCandidate = {
      #         #   "0" = "Tab";
      #         # };
      #         # "Hint Trigger" = {
      #         #   "0" = "Control+Alt+H";
      #         # };
      #         # "One Time Hint Trigger" = {
      #         #   "0" = "Control + Alt + J";
      #         # };
      #       };
      #     };
      #   };
      # };
    };
  };
}
