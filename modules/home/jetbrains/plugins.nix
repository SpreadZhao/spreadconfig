{
  pkgs,
  package,
  pluginsForIde,
}:

let
  ids = [
    "AceJump"
    "IdeaVIM"
    "org.jetbrains.IdeaVim-EasyMotion"
    "com.joshestein.ideavim-quickscope"
    "IdeaVimExtension"
    "izhangzhihao.rainbow.brackets.lite"
    "com.ahmed3elshaer.true-black-theme"
    "com.magidc.ideavim.anyObject"
    "com.julienphalip.ideavim.peekaboo"
    "eu.theblob42.idea.whichkey"
  ];
  resolved = pluginsForIde pkgs package ids;
  themeId = "com.ahmed3elshaer.true-black-theme";
  theme = resolved.${themeId};
  # 3.0.0 declares non-existent editor scheme parents for its Islands variants.
  # Loading any theme initializes every bundled scheme, including these variants.
  fixedTheme = pkgs.runCommand "true-dark-3.0.0-compatible.jar" { } ''
    ${pkgs.python3}/bin/python3 ${./scripts/fix-theme-parents.py} ${theme} "$out"
  '';
in
pkgs.lib.attrValues (
  resolved
  // pkgs.lib.optionalAttrs (theme.name == "${themeId}-3.0.0.jar") {
    ${themeId} = fixedTheme;
  }
)
