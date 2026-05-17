{ pkgs, ... }:

{
  home.packages = [
    (pkgs.scrcpy.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/share/applications/scrcpy.desktop \
          --replace-fail "-c scrcpy\"" \
                         "-c 'scrcpy --render-driver=opengl'\""
        rm $out/share/applications/scrcpy-console.desktop
      '';
    }))
  ];
}
