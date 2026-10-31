{ pkgs, ... }:

{
  nix.settings = {
    substituters = [ "https://codex-desktop-linux.cachix.org" ];
    trusted-public-keys = [
      "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk="
    ];
  };

  environment.etc."codex/config.toml".source = (pkgs.formats.toml { }).generate "codex-config.toml" {
    default_permissions = ":danger-full-access";
    approval_policy = "never";

    tui = {
      notifications = [
        "agent-turn-complete"
        "approval-requested"
        "async-question"
      ];
      notification_condition = "unfocused";
      notification_method = "bel";
    };

    desktop = {
      notifications-turn-mode = "unfocused";
      notifications-permissions-enabled = true;
      notifications-questions-enabled = true;
    };
  };
}
