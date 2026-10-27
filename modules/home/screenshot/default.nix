{ appEntries, pkgs, ... }:
{
  home.packages = [
    pkgs.grim
    pkgs.slurp
    pkgs.lswt
    (pkgs.tesseract.override {
      enableLanguages = [
        "chi_sim"
        "eng"
      ];
    })
  ];
  spreadconfig.scriptFiles = appEntries "screenshot" "scripts";
}
