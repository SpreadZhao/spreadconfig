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
  hostConfigDir = "${spreadconfigDir}/config/${hostName}";
  hostScriptsDir = "${spreadconfigDir}/scripts/${hostName}";
  hostConfigRoot = repoRoot + "/spreadconfig/config/${hostName}";
  hostScriptsRoot = repoRoot + "/spreadconfig/scripts/${hostName}";
  joinRuntimePath = root: rel: if rel == "" then root else "${root}/${rel}";
  joinCheckPath = root: rel: if rel == "" then root else root + "/${rel}";
  strictHostPath =
    kind: checkRoot: runtimeRoot: rel:
    let
      checkedPath = joinCheckPath checkRoot rel;
      runtimePath = joinRuntimePath runtimeRoot rel;
    in
    if builtins.pathExists checkedPath then
      runtimePath
    else
      throw "Missing host ${kind} for ${hostName}: ${runtimePath}";
  hostConfigPath = strictHostPath "config" hostConfigRoot hostConfigDir;
  hostScriptPath = strictHostPath "script" hostScriptsRoot hostScriptsDir;
  hostConfigSource = rel: config.lib.file.mkOutOfStoreSymlink (hostConfigPath rel);
  hostScriptSource = rel: config.lib.file.mkOutOfStoreSymlink (hostScriptPath rel);
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
    wayprompt = 26;
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
