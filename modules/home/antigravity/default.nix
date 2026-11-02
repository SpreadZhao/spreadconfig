{
  appSource,
  config,
  inputs,
  lib,
  pkgs,
  repoRoot,
  ...
}:

let
  packages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  settings = pkgs.writeText "antigravity-settings.json" (
    lib.fileContents (repoRoot + "/${appSource "antigravity" "files/settings.json"}")
  );
in
{
  home.packages = [ packages.antigravity-cli ];

  home.file.".gemini/config/skills" = lib.mkIf config.programs.naw.globalSkills.enable {
    inherit (config.home.file.".agents/skills") source;
    recursive = true;
  };

  # Antigravity rewrites settings.json at runtime, so activation seeds the
  # file only when it is missing or a symlink, and never overwrites an
  # existing regular file. Delete the file and activate again to re-seed it.
  home.activation.seedAntigravitySettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    dest="$HOME/.gemini/antigravity-cli/settings.json"
    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
      :
    else
      run ${pkgs.coreutils}/bin/mkdir -p -- "$HOME/.gemini/antigravity-cli"
      run ${pkgs.coreutils}/bin/rm -f -- "$dest"
      run ${pkgs.coreutils}/bin/install -m 600 -- ${settings} "$dest"
    fi
  '';
}
