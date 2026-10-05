{
  inputs,
  pkgs,
  repoEntries,
  ...
}:
let
  basePackage = inputs.fzf-popup.packages.${pkgs.stdenv.hostPlatform.system}.default;
  launcher = pkgs.writeShellApplication {
    name = "fzf-popup-foot";
    runtimeInputs = [ pkgs.foot ];
    text = builtins.readFile ./scripts/bin/fzf-popup-foot;
  };
  package = pkgs.symlinkJoin {
    name = "fzf-popup-foot-configured";
    paths = [ basePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    passthru = { inherit launcher basePackage; };
    postBuild = ''
      wrapProgram "$out/bin/fzf-popup" \
        --set-default FZF_POPUP_LAUNCHER "${launcher}/bin/fzf-popup-foot"
    '';
  };
in
{
  _module.args.fzfPopupPackage = package;
  home.packages = [ package ];
  spreadconfig.scriptFiles = repoEntries "modules/home/fzf-popup/scripts";
}
