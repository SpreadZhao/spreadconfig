{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  ghHostsFile = "${config.xdg.configHome}/gh/hosts.yml";
  ghTokenFile = osConfig.sops.secrets."github-token".path;
  writeGhHosts = pkgs.writeShellScript "write-gh-hosts" ''
    set -euo pipefail

    token_file=$1
    hosts_file=$2

    [ -s "$token_file" ] || exit 0
    token="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$token_file")"
    [ -n "$token" ] || exit 0

    ${pkgs.coreutils}/bin/install -d -m 700 "$(${pkgs.coreutils}/bin/dirname "$hosts_file")"
    ${pkgs.coreutils}/bin/install -m 600 /dev/null "$hosts_file"
    ${pkgs.coreutils}/bin/printf "%s\n" \
      "github.com:" \
      "    user: SpreadZhao" \
      "    oauth_token: $token" \
      "    git_protocol: https" > "$hosts_file"
  '';
in
{
  home.packages = [ pkgs.gh ];

  home.activation.writeGhHosts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${writeGhHosts} ${lib.escapeShellArg ghTokenFile} ${lib.escapeShellArg ghHostsFile}
  '';
}
