{ pkgs, ... }:

{
  home.packages = [
    (pkgs.tesseract.override {
      enableLanguages = [
        "chi_sim"
        "eng"
      ];
    })
  ];
}
