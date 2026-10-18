{
  lib,
  pkgs,
  ides,
  sdkPath,
}:

let
  settings = pkgs.writeText "jetbrains-settings.json" (
    builtins.toJSON {
      ides = map (ide: {
        inherit (ide) id configDirectory;
      }) ides;
      themeSource = ./files/SpreadZhao_Dark.icls;
      themeId = "ae7a917c-04b2-4468-bab7-6ddd4c43f879";
      schemeName = "SpreadZhao";
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
