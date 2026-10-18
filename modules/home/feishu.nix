{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.feishu ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/feishu"
    "x-scheme-handler/feishu-open"
    "x-scheme-handler/lark"
    "x-scheme-handler/x-feishu"
  ] (_: "bytedance-feishu.desktop");
}
