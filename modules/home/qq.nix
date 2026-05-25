{ pkgs, ... }:

{
  home.packages = [
    (pkgs.qq.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/share/applications/qq.desktop \
          --replace-fail "$out/bin/qq" "$out/bin/qq --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3"
      '';
    }))
  ];
}
