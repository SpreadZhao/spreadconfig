{ pkgs, ... }:

{
  home.packages = [
    (pkgs.texliveBasic.withPackages (ps: [
      ps.scontents
      ps.standalone
      ps.varwidth
      ps.xcolor
    ]))
  ];
}
