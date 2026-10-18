{
  config,
  lib,
  pkgs,
  ides,
  sdkPath,
}:

let
  settings = pkgs.writeText "jetbrains-settings.json" (
    builtins.toJSON {
      homeDirectory = config.home.homeDirectory;
      stateDirectory = "${config.xdg.stateHome}/jetbrains";
      ides = map (ide: {
        inherit (ide) id configDirectory;
      }) ides;
      themeSource = ./files/SpreadZhao_Dark.icls;
      themeId = "ae7a917c-04b2-4468-bab7-6ddd4c43f879";
      schemeName = "SpreadZhao";
      # Freeze the old deployment's value: later JDK updates must not change
      # which user property this one-time migration is allowed to remove.
      legacyGradleJavaHome = "/nix/store/2cv1b5y6h029cvg07c944pq89fszwbya-openjdk-21.0.12.1+1/lib/openjdk";
      androidSdkPath = sdkPath;
      toolchain = {
        cc = "${pkgs.stdenv.cc}/bin/cc";
        cxx = "${pkgs.stdenv.cc}/bin/c++";
        cmake = lib.getExe pkgs.cmake;
        ninja = lib.getExe pkgs.ninja;
        gdb = lib.getExe pkgs.gdb;
      };
    }
  );
in
pkgs.writeShellApplication {
  name = "jetbrains-apply-settings";
  runtimeInputs = [ pkgs.python3 ];
  text = ''
    exec python3 ${./scripts/apply-settings.py} --config ${settings} "$@"
  '';
}
