{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:

let
  ghHostsFile = "${config.xdg.configHome}/gh/hosts.yml";
  ghTokenFile = "${secretsDir}/gh_token";
in

{
  home.packages = [ pkgs.gh ];

  home.activation.writeGhHosts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    token_file=${lib.escapeShellArg ghTokenFile}
    hosts_file=${lib.escapeShellArg ghHostsFile}

    if [ -s "$token_file" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$hosts_file")"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod 700 "$(${pkgs.coreutils}/bin/dirname "$hosts_file")"

      token="$(${pkgs.coreutils}/bin/cat "$token_file")"
      token="$(${pkgs.coreutils}/bin/printf '%s' "$token" | ${pkgs.gnused}/bin/sed 's/[[:space:]]*$//')"

      if [ -n "$token" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 600 /dev/null "$hosts_file"
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash -c '
          hosts_file=$1
          token=$2

          ${pkgs.coreutils}/bin/printf "%s\n" \
            "github.com:" \
            "    user: SpreadZhao" \
            "    oauth_token: $token" \
            "    git_protocol: https" > "$hosts_file"
        ' gh-hosts "$hosts_file" "$token"
      fi
    fi
  '';
}
