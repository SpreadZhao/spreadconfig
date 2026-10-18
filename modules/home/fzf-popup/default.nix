{
  config,
  inputs,
  lib,
  pkgs,
  appEntries,
  appSource,
  repoRoot,
  ...
}:
let
  basePackage = inputs.fzf-popup.packages.${pkgs.stdenv.hostPlatform.system}.default;
  launcher = pkgs.writeShellApplication {
    name = "fzf-popup-foot";
    runtimeInputs = [ pkgs.foot ];
    text = builtins.readFile (repoRoot + "/${appSource "fzf-popup" "scripts/bin/fzf-popup-foot"}");
  };
in
{
  home.packages = [ basePackage ];
  home.sessionVariables.FZF_POPUP_LAUNCHER = lib.getExe launcher;
  systemd.user.sessionVariables.FZF_POPUP_LAUNCHER = config.home.sessionVariables.FZF_POPUP_LAUNCHER;
  spreadconfig.scriptFiles = appEntries "fzf-popup" "scripts";
}
