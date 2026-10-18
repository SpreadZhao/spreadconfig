{
  appEntries,
  repoTree,
  pkgs,
  lib,
  ...
}:

{
  home.packages = [
    pkgs.source-code-pro
    pkgs.swayimg
  ];

  xdg.configFile."swayimg".source = repoTree "swayimg" (appEntries "swayimg" "files");

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heic"
    "image/heif"
    "image/jpeg"
    "image/jpg"
    "image/jxl"
    "image/pbm"
    "image/pjpeg"
    "image/png"
    "image/svg+xml"
    "image/tiff"
    "image/webp"
    "image/x-bmp"
    "image/x-exr"
    "image/x-pcx"
    "image/x-png"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-targa"
    "image/x-tga"
    "image/x-xbitmap"
  ] (_: "swayimg.desktop");
}
