{ lib, ... }:

{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
    hosts = {
      "github.com" = {
        user = "SpreadZhao";
        oauth_token = lib.strings.trim (builtins.readFile ../../../secrets/gh_token);
        git_protocol = "https";
      };
    };
  };
}
