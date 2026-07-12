{
  hostConfigSource,
  lib,
  pkgs,
  ...
}:

let
  enable = false;
in
lib.mkIf enable {
  home.packages = [
    (pkgs.feh.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/share/applications/feh.desktop \
          --replace-fail "Exec=feh --start-at %u" \
                         "Exec=feh --theme fit --start-at %u"
      '';
    }))
  ];

  xdg.configFile."feh".source = hostConfigSource "feh";
}
