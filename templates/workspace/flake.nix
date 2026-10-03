{
  description = "Agent workspace";

  inputs.spreadconfig.url = "github:SpreadZhao/spreadconfig";

  outputs =
    { spreadconfig, ... }:
    spreadconfig.lib.mkWorkspace {
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
