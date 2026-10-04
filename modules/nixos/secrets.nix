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

    templates = {
      "gh-hosts.yml" = {
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
      "claude-settings.json" = {
        owner = "spreadzhao";
        group = "users";
        mode = "0400";
        content = builtins.toJSON {
          model = "glm-5.3";
          env = {
            ANTHROPIC_AUTH_TOKEN = config.sops.placeholder."glm-api-key";
            ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic";
            ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.3";
            ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.3";
            ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-5.3";
            CLAUDE_CODE_DISABLE_1M_CONTEXT = "1";
            CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
            API_TIMEOUT_MS = "3000000";
          };
        };
      };
    };

    secrets = {
      glm-api-key = {
        owner = "spreadzhao";
        group = "users";
        mode = "0400";
      };

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
