{ pkgs, config }:

let
  androidEnv = pkgs.androidenv.override { licenseAccepted = true; };
  composition = androidEnv.composeAndroidPackages {
    platformVersions = [
      "34"
      "36"
      "37.0"
    ];
    buildToolsVersions = [
      "34.0.0"
      "35.0.0"
      "36.0.0"
      "37.0.0"
    ];
    platformToolsVersion = "37.0.1";
    cmdLineToolsVersion = "22.0";
    toolsVersion = null;
    includeSources = true;
    includeEmulator = false;
    includeSystemImages = false;
    includeNDK = false;
    includeCmake = false;
  };
  package = composition.androidsdk;
  path = "${config.xdg.userDirs.extraConfig.LIB}/Android/Sdk";
in
{
  inherit package path;
}
