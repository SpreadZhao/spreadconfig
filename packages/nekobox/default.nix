{
  appimageTools,
  fetchurl,
  lib,
  makeDesktopItem,
  nix-update-script,
}:

let
  pname = "nekobox";
  version = "5.11.26";
  src = fetchurl {
    url = "https://github.com/qr243vbi/nekobox/releases/download/${version}/nekobox-${version}-x86_64-linux.AppImage";
    hash = "sha256-WwTwRV9Wi7ZtQuS8ydGxJvHGhHNqffC23xQFXoEkMpo=";
  };
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
  desktopItem = makeDesktopItem {
    name = "nekobox";
    exec = "nekobox %U";
    icon = "nekobox";
    desktopName = "Neko Box";
    genericName = "Proxy Client";
    comment = "Qt proxy utility powered by sing-box";
    categories = [
      "Network"
    ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  passthru = {
    inherit src;
    updateScript = nix-update-script {
      attrPath = pname;
      extraArgs = [ "--flake" ];
    };
  };

  extraInstallCommands = ''
    install -Dm444 "${desktopItem}/share/applications/nekobox.desktop" \
      "$out/share/applications/nekobox.desktop"

    icon="$(find "${appimageContents}" -type f \( -iname 'nekobox.png' -o -iname 'nekobox.svg' -o -iname 'nyamebox.png' \) | head -n 1 || true)"
    if [ -n "$icon" ]; then
      case "$icon" in
        *.svg)
          install -Dm444 "$icon" "$out/share/icons/hicolor/scalable/apps/nekobox.svg"
          ;;
        *)
          install -Dm444 "$icon" "$out/share/icons/hicolor/256x256/apps/nekobox.png"
          ;;
      esac
    fi
  '';

  meta = {
    description = "Qt proxy utility powered by sing-box";
    homepage = "https://github.com/qr243vbi/nekobox";
    license = lib.licenses.gpl3Only;
    mainProgram = "nekobox";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
