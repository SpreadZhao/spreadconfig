{ config, repoRoot, ... }:

{
  sops = {
    defaultSopsFile = repoRoot + "/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";

    # Provision once with scripts/sops-key init (before installation/rebuild).
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = false;
      sshKeyPaths = [ ];
    };
    gnupg.sshKeyPaths = [ ];

    templates."gh-hosts.yml" = {
      owner = "spreadzhao";
      group = "users";
      mode = "0400";
      # JSON is valid YAML; only placeholders enter the Nix store.
      content = builtins.toJSON {
        "github.com" = {
          user = "SpreadZhao";
          git_protocol = "https";
          oauth_token = config.sops.placeholder."github-token";
          users.SpreadZhao.oauth_token = config.sops.placeholder."github-token";
        };
      };
    };

    secrets = {
      github-token = {
        owner = "spreadzhao";
        group = "users";
        mode = "0400";
      };

      textbridge-token = {
        owner = "spreadzhao";
        group = "users";
        mode = "0400";
      };

      spreadzhao-password-hash.neededForUsers = true;
    };
  };
}
