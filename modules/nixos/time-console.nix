{ pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    colors = [
      "000000"
      "bc3f3c"
      "6a9955"
      "e6e6aa"
      "47a2ed"
      "bc3f3c"
      "47ccb1"
      "d4d4d4"
      "72737a"
      "ff6b6b"
      "b4cda8"
      "d7ba7d"
      "8cd7ff"
      "e49ad8"
      "5fe0c6"
      "ffffff"
    ];
  };
}
