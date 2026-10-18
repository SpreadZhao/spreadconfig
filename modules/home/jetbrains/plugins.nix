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
    ${pkgs.python3}/bin/python3 - ${theme} "$out" <<'PY'
    import sys
    import zipfile

    parents = {
        "TrueBlackIslands.xml": (b'parent_scheme="Islands Dark"', b'parent_scheme="Darcula"'),
        "TrueDarkIslands.xml": (b'parent_scheme="Islands Dark"', b'parent_scheme="Darcula"'),
        "TrueLightIslands.xml": (b'parent_scheme="Islands Light"', b'parent_scheme="Default"'),
    }
    with zipfile.ZipFile(sys.argv[1]) as source, zipfile.ZipFile(sys.argv[2], "w") as target:
        for entry in source.infolist():
            data = source.read(entry)
            if entry.filename in parents:
                old, new = parents.pop(entry.filename)
                assert data.count(old) == 1, entry.filename
                data = data.replace(old, new)
            target.writestr(entry, data)
    assert not parents, parents
    PY
  '';
in
pkgs.lib.attrValues (
  resolved
  // pkgs.lib.optionalAttrs (theme.name == "${themeId}-3.0.0.jar") {
    ${themeId} = fixedTheme;
  }
)
