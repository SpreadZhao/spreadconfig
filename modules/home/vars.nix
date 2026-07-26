{
  config,
  hostName,
  hostProfile,
  lib,
  pkgs,
  repoRoot,
  ...
}:

let
  hostHomeProfile = hostProfile.home or { };
  installedJDKs = with pkgs; [
    jdk25
    jdk21
    jdk17
    jdk11
    jdk8
  ];
  defaultJDK = builtins.elemAt installedJDKs 0;
  projDir = "${config.xdg.userDirs.extraConfig.WORKSPACE}/spreadconfig";
  scriptsDir = "${config.home.homeDirectory}/scripts";
  secretsDir = "${projDir}/secrets";
  spreadconfigDir = "${projDir}/spreadconfig";
  defaultConfigDir = "${spreadconfigDir}/config/default";
  defaultScriptsDir = "${spreadconfigDir}/scripts/default";
  hostConfigDir = "${spreadconfigDir}/config/${hostName}";
  hostScriptsDir = "${spreadconfigDir}/scripts/${hostName}";
  defaultConfigRoot = repoRoot + "/spreadconfig/config/default";
  defaultScriptsRoot = repoRoot + "/spreadconfig/scripts/default";
  hostConfigRoot = repoRoot + "/spreadconfig/config/${hostName}";
  hostScriptsRoot = repoRoot + "/spreadconfig/scripts/${hostName}";
  joinRuntimePath = root: rel: if rel == "" then root else "${root}/${rel}";
  joinCheckPath = root: rel: if rel == "" then root else root + "/${rel}";
  sourceName =
    kind: rel:
    "spreadconfig-${hostName}-${kind}-${
      if rel == "" then "root" else lib.replaceStrings [ "/" "." ] [ "-" "-" ] rel
    }";
  linkTreeCommands =
    checkRoot: runtimeRoot:
    if builtins.pathExists checkRoot then
      ''
        check_root=${checkRoot}
        runtime_root=${lib.escapeShellArg runtimeRoot}

        while IFS= read -r -d "" dir; do
          mkdir -p "$out/$dir"
        done < <(cd "$check_root" && find . -type d -printf '%P\0')

        while IFS= read -r -d "" file; do
          target="$out/$file"
          mkdir -p "$(dirname "$target")"
          rm -rf "$target"
          ln -s "$runtime_root/$file" "$target"
        done < <(cd "$check_root" && find . \( -type f -o -type l \) -printf '%P\0')
      ''
    else
      "";
  mergedSource =
    kind: rel: defaultCheck: hostCheck: defaultRuntime: hostRuntime:
    pkgs.runCommandLocal (sourceName kind rel) { } ''
      mkdir -p "$out"
      ${linkTreeCommands defaultCheck defaultRuntime}
      ${linkTreeCommands hostCheck hostRuntime}
    '';
  fallbackPath =
    kind: defaultCheckRoot: hostCheckRoot: defaultRuntimeRoot: hostRuntimeRoot: rel:
    let
      defaultCheckPath = joinCheckPath defaultCheckRoot rel;
      hostCheckPath = joinCheckPath hostCheckRoot rel;
      defaultRuntimePath = joinRuntimePath defaultRuntimeRoot rel;
      hostRuntimePath = joinRuntimePath hostRuntimeRoot rel;
      defaultExists = builtins.pathExists defaultCheckPath;
      hostExists = builtins.pathExists hostCheckPath;
    in
    if hostExists then
      hostRuntimePath
    else if defaultExists then
      defaultRuntimePath
    else
      throw "Missing ${kind} for ${hostName}: ${hostRuntimePath} (fallback: ${defaultRuntimePath})";
  fallbackSource =
    kind: defaultCheckRoot: hostCheckRoot: defaultRuntimeRoot: hostRuntimeRoot: rel:
    let
      defaultCheckPath = joinCheckPath defaultCheckRoot rel;
      hostCheckPath = joinCheckPath hostCheckRoot rel;
      defaultRuntimePath = joinRuntimePath defaultRuntimeRoot rel;
      hostRuntimePath = joinRuntimePath hostRuntimeRoot rel;
      defaultExists = builtins.pathExists defaultCheckPath;
      hostExists = builtins.pathExists hostCheckPath;
      defaultIsDir = defaultExists && lib.pathIsDirectory defaultCheckPath;
      hostIsDir = hostExists && lib.pathIsDirectory hostCheckPath;
      defaultIsFile = defaultExists && lib.pathIsRegularFile defaultCheckPath;
      hostIsFile = hostExists && lib.pathIsRegularFile hostCheckPath;
    in
    if defaultIsDir || hostIsDir then
      if (defaultIsFile || hostIsFile) then
        throw "Mismatched ${kind} path types for ${hostName}: ${hostRuntimePath} and ${defaultRuntimePath}"
      else
        mergedSource kind rel defaultCheckPath hostCheckPath defaultRuntimePath hostRuntimePath
    else if hostExists then
      config.lib.file.mkOutOfStoreSymlink hostRuntimePath
    else if defaultExists then
      config.lib.file.mkOutOfStoreSymlink defaultRuntimePath
    else
      throw "Missing ${kind} for ${hostName}: ${hostRuntimePath} (fallback: ${defaultRuntimePath})";
  hostConfigPath =
    fallbackPath "config" defaultConfigRoot hostConfigRoot defaultConfigDir
      hostConfigDir;
  hostScriptPath =
    fallbackPath "script" defaultScriptsRoot hostScriptsRoot defaultScriptsDir
      hostScriptsDir;
  hostConfigSource =
    fallbackSource "config" defaultConfigRoot hostConfigRoot defaultConfigDir
      hostConfigDir;
  hostScriptSource =
    fallbackSource "script" defaultScriptsRoot hostScriptsRoot defaultScriptsDir
      hostScriptsDir;
  mochaBg = "0e1117";
  theme_tranparent = "00000000";
  theme_background = "000000";
  theme_red = "bc3f3c";
  theme_green = "6a9955";
  theme_yellow = "e6e6aa";
  theme_blue = "47a2ed";
  theme_purple = "3181a7";
  theme_magenta = "bc3f3c";
  theme_cyan = "47ccb1";
  theme_white = "d4d4d4";
  theme_bright_background = "3a3a3a";
  theme_bright_dark = "72737a";
  theme_bright_red = "ff0000";
  theme_bright_blue = "8cd7ff";
  theme_bright_white = "ffffff";
  theme_bright_yellow = "ffc66d";
  theme_radius = "0";
  fontFamilies = {
    sans = "Noto Sans";
    mono = "Noto Sans Mono";
    serif = "Noto Serif";
    emoji = "Noto Color Emoji";
    nerdMono = "Symbols Nerd Font Mono";
  };
  fontFallbacks = {
    emoji = [ fontFamilies.emoji ];
    monospace = [
      fontFamilies.mono
      "Noto Sans Mono CJK SC"
      "Noto Sans Mono CJK HK"
      "Noto Sans Mono CJK TC"
      "Noto Sans Mono CJK JP"
      "Noto Sans Mono CJK KR"
      fontFamilies.nerdMono
      fontFamilies.emoji
    ];
    sansSerif = [
      fontFamilies.sans
      "Noto Sans CJK SC"
      "Noto Sans CJK HK"
      "Noto Sans CJK TC"
      "Noto Sans CJK JP"
      "Noto Sans CJK KR"
      fontFamilies.emoji
    ];
    serif = [
      fontFamilies.serif
      "Noto Serif CJK SC"
      "Noto Serif CJK HK"
      "Noto Serif CJK TC"
      "Noto Serif CJK JP"
      "Noto Serif CJK KR"
      fontFamilies.emoji
    ];
  };
  baseFontSizes = {
    gtk = 16;
    qt = 16;
    foot = 16;
    kitty = 16;
    fuzzel = 18;
    swaylock = 30;
    fnott = {
      title = 20;
      summary = 19;
      body = 18;
    };
  };
  fontScalePercent = hostHomeProfile.fontScalePercent or 100;
  scaleFontSize = size: builtins.div (size * fontScalePercent + 50) 100;
  scaleFontSizes =
    value:
    if builtins.isAttrs value then builtins.mapAttrs (_: scaleFontSizes) value else scaleFontSize value;
  fontSizes = lib.recursiveUpdate (scaleFontSizes baseFontSizes) (hostHomeProfile.fontSizes or { });
in
{
  _module.args = {
    inherit
      installedJDKs
      defaultJDK
      projDir
      scriptsDir
      secretsDir
      spreadconfigDir
      hostConfigDir
      hostScriptsDir
      hostConfigPath
      hostScriptPath
      hostConfigSource
      hostScriptSource
      mochaBg
      theme_tranparent
      theme_background
      theme_red
      theme_green
      theme_yellow
      theme_blue
      theme_purple
      theme_magenta
      theme_cyan
      theme_white
      theme_bright_background
      theme_bright_dark
      theme_bright_red
      theme_bright_blue
      theme_bright_white
      theme_bright_yellow
      theme_radius
      fontFamilies
      fontFallbacks
      fontSizes
      ;
  };
}
