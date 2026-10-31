{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  packages = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
  figmaGuide = inputs.figma-mcp-server-guide;
  figmaPython = pkgs.python3.withPackages (ps: [ ps.pillow ]);
  # Antigravity loads mcp_config.json from the plugin root rather than
  # .antigravity-plugin/. Override its broken built-in Figma OAuth client ID
  # (WPjiIBOlI6Snc0EeAjsit7) with a working DCR client registered for
  # https://antigravity.google/oauth-callback, and provide Pillow to
  # video-interaction-mapper.
  figmaPlugin =
    pkgs.runCommand "antigravity-figma-plugin"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        mkdir -p "$out/skills"
        jq 'del(.category, .mcpServers)' \
          "${figmaGuide}/.antigravity-plugin/plugin.json" > "$out/plugin.json"
        jq '.mcpServers.figma.oauth = {
          clientId: "q2h2inS4FlaPb56utZ54Lu",
          clientSecret: "3LOlrH7fjL1cSTULPWLpM2bCbo8Auxv1ERcokyFZ"
        }' "${figmaGuide}/.antigravity-plugin/mcp_config.json" > "$out/mcp_config.json"
        cp "${figmaGuide}/Figma Icon (Full-color).svg" "$out/Figma Icon (Full-color).svg"
        cp "${figmaGuide}/README.md" "$out/README.md"
        cp -r "${figmaGuide}/skills/." "$out/skills/"
        cp -r "${figmaGuide}/workflow-skills/." "$out/skills/"
        chmod -R u+w "$out/skills/video-interaction-mapper"
        substituteInPlace "$out/skills/video-interaction-mapper/SKILL.md" \
          --replace-fail "python <SKILL_DIR>/scripts/" "${figmaPython}/bin/python3 <SKILL_DIR>/scripts/"
        for script in "$out/skills/video-interaction-mapper/scripts/"*.py; do
          substituteInPlace "$script" \
            --replace-fail "#!/usr/bin/env python3" "#!${figmaPython}/bin/python3"
          chmod +x "$script"
        done
      '';
  # Bypass org.freedesktop.secrets so starting Antigravity does not unlock
  # pass-secret-service via gpg-agent. --password-store=basic disables
  # Chromium's OS keyring integration, and /.dockerenv inside the FHS sandbox
  # makes the bundled language_server store its OAuth token in
  # ~/.gemini/jetski-standalone-oauth-token instead of Secret Service.
  antigravity =
    let
      base = packages.google-antigravity.override {
        browserPkg = pkgs.chromium;
        extraBwrapArgs = [ "--ro-bind /dev/null /.dockerenv" ];
      };
    in
    pkgs.symlinkJoin {
      inherit (base) pname version meta;
      paths = [ base ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/antigravity" \
          --append-flags '--password-store=basic'
      '';
    };
in
{
  home.packages = [
    antigravity
    packages.google-antigravity-cli
  ];

  home.file = {
    ".gemini/config/plugins/figma" = {
      source = figmaPlugin;
      recursive = true;
    };
    ".gemini/config/skills" = lib.mkIf config.programs.naw.globalSkills.enable {
      inherit (config.home.file.".agents/skills") source;
      recursive = true;
    };
  };

  xdg.mimeApps = {
    defaultApplications."x-scheme-handler/antigravity" = "antigravity.desktop";
    associations.added."x-scheme-handler/antigravity" = "antigravity.desktop";
  };
}
