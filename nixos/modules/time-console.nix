{ pkgs, ... }:

{
    time.timeZone = "Asia/Shanghai";

    console = {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    };
}
