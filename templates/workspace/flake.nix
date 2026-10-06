{
  description = "Agent workspace";

  inputs = {
    spreadconfig.url = "github:SpreadZhao/spreadconfig";
    agent-workspace.follows = "spreadconfig/agent-workspace";
  };

  outputs =
    { agent-workspace, spreadconfig, ... }:
    agent-workspace.lib.mkWorkspace {
      catalog = spreadconfig.lib.skillCatalog;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      skills = [ ]; # e.g. "leetcode-coach", "run-paper-reading-workflow"
      packages = pkgs: [
        pkgs.git
        pkgs.ripgrep
      ];
      claude = false;

      instructions = "";
    };
}
