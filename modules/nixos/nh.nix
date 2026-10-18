{ ... }:

{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--no-direnv";
    flake = "/home/spreadzhao/workspaces/spreadconfig";
  };
}
