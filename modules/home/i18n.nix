{
  inputs,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
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
        fcitx5-mozc
        inputs.textbridge.packages.${system}.fcitx5-textbridge
      ];
      settings = {
        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = true;
            TriggerKeys = "";
            AltTriggerKeys = "";
            EnumerateBackwardKeys = "";
            EnumerateGroupForwardKeys = "";
            EnumerateGroupBackwardKeys = "";
            EnumerateSkipFirst = false;
            ModifierOnlyKeyTimeout = 250;
          };
          "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
          "Hotkey/DeactivateKeys"."0" = "Hangul_Romaja";
          "Hotkey/EnumerateForwardKeys"."0" = "Control+space";
          "Hotkey/PrevPage"."0" = "Up";
          "Hotkey/NextPage"."0" = "Down";
          "Hotkey/PrevCandidate"."0" = "Shift+Tab";
          "Hotkey/NextCandidate"."0" = "Tab";
          "Hotkey/TogglePreedit"."0" = "Control+Alt+P";
          Behavior = {
            ActiveByDefault = false;
            resetStateWhenFocusIn = "No";
            ShareInputState = "No";
            PreeditEnabledByDefault = true;
            ShowInputMethodInformation = true;
            showInputMethodInformationWhenFocusIn = false;
            CompactInputMethodInformation = true;
            ShowFirstInputMethodInformation = true;
            DefaultPageSize = 5;
            OverrideXkbOption = false;
            CustomXkbOption = "";
            EnabledAddons = "";
            DisabledAddons = "";
            PreloadInputMethod = true;
            AllowInputMethodForPassword = false;
            ShowPreeditForPassword = false;
            AutoSavePeriod = 30;
          };
        };
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "rime";
          };
          "Groups/0/Items/0" = {
            Name = "rime";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
          GroupOrder."0" = "Default";
        };
        addons = {
          keyboard = {
            globalSection = {
              PageSize = 9;
              EnableEmoji = true;
              EnableQuickPhraseEmoji = true;
              "Choose Modifier" = "Alt";
              EnableHintByDefault = false;
              UseNewComposeBehavior = true;
              EnableLongPress = false;
            };
            sections = {
              PrevCandidate."0" = "Shift+Tab";
              NextCandidate."0" = "Tab";
              "Hint Trigger"."0" = "Control+Alt+H";
              "One Time Hint Trigger"."0" = "Control+Alt+J";
              LongPressBlocklist = {
                "0" = "konsole";
                "1" = "org.kde.konsole";
              };
            };
          };
          unicode.globalSection.DirectUnicodeMode = "";
          classicui.globalSection = {
            "Vertical Candidate List" = false;
            WheelForPaging = true;
            Font = "\"Noto Sans 18\"";
            MenuFont = "\"Noto Sans 10\"";
            TrayFont = "\"Noto Sans 10\"";
            TrayOutlineColor = "#000000";
            TrayTextColor = "#ffffff";
            PreferTextIcon = true;
            ShowLayoutNameInIcon = true;
            UseInputMethodLanguageToDisplayText = true;
            Theme = "default-dark";
            DarkTheme = "default-dark";
            UseDarkTheme = false;
            UseAccentColor = false;
            PerScreenDPI = false;
            ForceWaylandDPI = 0;
            EnableFractionalScale = true;
          };
        };
      };
    };
  };

  xdg.configFile."fcitx5" = {
    recursive = true;
    force = true;
  };
}
