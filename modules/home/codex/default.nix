{
  appSource,
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
  sharedSettings = pkgs.writeText "codex-config.toml" (
    lib.fileContents (repoRoot + "/${appSource "codex" "files/config.toml"}")
  );
in
{
  home.packages = builtins.attrValues (
    import ./profiles.nix {
      inherit lib pkgs;
      names = profileNames;
      codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
    }
  );

  # Codex appends project trust and other runtime settings to config.toml, so
  # activation seeds the file only when it is missing or a symlink, and never
  # overwrites an existing regular file. Delete a profile's config.toml and
  # activate again to re-seed it.
  home.activation.seedCodexConfigs = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
    ${lib.concatMapStringsSep "\n" (profile: ''
      dest="$data_home/codex/profiles/${profile}/config.toml"
      if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        :
      else
        run ${pkgs.coreutils}/bin/mkdir -p -- "$data_home/codex/profiles/${profile}"
        run ${pkgs.coreutils}/bin/rm -f -- "$dest"
        run ${pkgs.coreutils}/bin/install -m 600 -- ${sharedSettings} "$dest"
      fi
    '') profileNames}
  '';
}
