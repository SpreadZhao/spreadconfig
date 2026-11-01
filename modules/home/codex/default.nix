{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  profileNames = [
    "spreadzhao"
    "supazodiac"
  ];
  sharedSettings = (pkgs.formats.toml { }).generate "codex-config.toml" {
    default_permissions = ":danger-full-access";
    approval_policy = "never";

    tui = {
      status_line = [
        "model-with-reasoning"
        "current-dir"
        "context-used"
        "weekly-limit"
        "used-tokens"
        "project-name"
      ];
      status_line_use_colors = true;
      notifications = [
        "agent-turn-complete"
        "approval-requested"
        "async-question"
        "plan-mode-prompt"
      ];
      notification_condition = "unfocused";
      notification_method = "osc9";
    };

    mcp_servers.playwright = {
      command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
      args = [ "--extension" ];
      startup_timeout_sec = 30;
    };
  };
  profiles = import ./profiles.nix {
    inherit lib pkgs;
    names = profileNames;
    codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  };
in
{
  home.packages = builtins.attrValues profiles;

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
