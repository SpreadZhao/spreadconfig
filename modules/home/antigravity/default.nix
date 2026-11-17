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
  profileNames = [
    "spreadzhao"
    "supazodiac"
  ];

  antigravityPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli;

  # auth.NewCLITokenStorage hardcodes useFile = false and queries
  # org.freedesktop.secrets at startup, triggering pass-secret-service GPG prompts.
  # WSL_INTEROP=1 makes shouldBypassKeyring() select file-based token storage, and
  # --gemini_dir isolates application data and personal customizations.
  profiles = lib.genAttrs profileNames (
    profile:
    pkgs.writeShellApplication {
      name = "agy-${profile}";
      text = ''
        export WSL_INTEROP=1
        umask 077
        export ANTIGRAVITY_GEMINI_DIR="${config.xdg.dataHome}/antigravity/profiles/${profile}"
        mkdir -p -- "$ANTIGRAVITY_GEMINI_DIR"
        exec ${antigravityPackage}/bin/agy --gemini_dir="$ANTIGRAVITY_GEMINI_DIR" "$@"
      '';
      meta = {
        description = "Antigravity CLI with the ${profile} account profile";
        mainProgram = "agy-${profile}";
      };
    }
  );

  settings = pkgs.writeText "antigravity-settings.json" (
    lib.fileContents (repoRoot + "/${appSource "antigravity" "files/settings.json"}")
  );
in
{
  home.packages = builtins.attrValues profiles;

  systemd.user.services = lib.listToAttrs (
    map (profile: {
      name = "antigravity-remote-control-${profile}";
      value = {
        Unit = {
          Description = "Antigravity remote-control daemon (${profile})";
          After = [ "network.target" ];
          ConditionPathExists = "${config.xdg.dataHome}/antigravity/profiles/${profile}/antigravity-cli/antigravity-oauth-token";
          StartLimitIntervalSec = 0;
        };
        Service = {
          Type = "simple";
          ExecStart = "${lib.getExe profiles.${profile}} remote-control serve";
          Restart = "on-failure";
          RestartSec = 10;
          RestartPreventExitStatus = [ 3 ];
          TimeoutStopSec = 30;
        };
        Install.WantedBy = [ "default.target" ];
      };
    }) profileNames
  );

  home.file = lib.mkIf config.programs.naw.globalSkills.enable (
    lib.genAttrs
      (map (profile: "${config.xdg.dataHome}/antigravity/profiles/${profile}/config/skills") profileNames)
      (_: {
        inherit (config.home.file.".agents/skills") source;
        recursive = true;
      })
  );

  # Antigravity rewrites settings.json at runtime, so activation seeds each
  # profile only when the file is missing or a symlink, and never overwrites an
  # existing regular file. Delete a profile's settings.json and activate again
  # to re-seed it.
  home.activation.seedAntigravitySettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${lib.concatMapStringsSep "\n" (profile: ''
      dest="${config.xdg.dataHome}/antigravity/profiles/${profile}/antigravity-cli/settings.json"
      if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        :
      else
        run ${pkgs.coreutils}/bin/mkdir -p -- "${config.xdg.dataHome}/antigravity/profiles/${profile}/antigravity-cli"
        run ${pkgs.coreutils}/bin/rm -f -- "$dest"
        run ${pkgs.coreutils}/bin/install -m 600 -- ${settings} "$dest"
      fi
    '') profileNames}
  '';
}
