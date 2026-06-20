{ repoRoot, ... }:

{
  sops = {
    defaultSopsFile = repoRoot + "/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

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
