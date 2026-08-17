{
  hostProfile,
  lib,
  pkgs,
  ...
}:

let
  videoDecodeDevice = hostProfile.home.videoDecodeDevice or null;
  wrapperArgs = [
    "--add-flag"
    "--password-store=basic"
  ]
  ++ lib.optionals (videoDecodeDevice != null) [
    "--set"
    "LIBVA_DRIVER_NAME"
    "iHD"
    "--add-flag"
    "--hardware-video-device-path=${videoDecodeDevice}"
    "--add-flag"
    "--enable-features=AcceleratedVideoDecodeLinuxGL"
  ];
  chromiumPackage = pkgs.symlinkJoin {
    name = "chromium-basic-password-store";
    paths = [ pkgs.chromium ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/chromium ${lib.escapeShellArgs wrapperArgs}
    '';
  };
in
{
  home.packages = [ chromiumPackage ];
}
