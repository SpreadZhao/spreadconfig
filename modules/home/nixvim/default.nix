{ lib, ... }: {
  programs.nixvim = {
    enable = true;
    nixpkgs.useGlobalPackages = true;
    defaultEditor = true;
    imports = [
      ./core.nix
      ./keymaps.nix
      ./ui
      ./plugins
      ./lsp
    ];
  };

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "application/json"
    "application/schema+json"
    "application/sql"
    "application/toml"
    "application/x-ndjson"
    "application/x-shellscript"
    "application/xml"
    "application/yaml"
    "text/css"
    "text/javascript"
    "text/markdown"
    "text/plain"
    "text/rust"
    "text/vnd.trolltech.linguist"
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-cmake"
    "text/x-csrc"
    "text/x-go"
    "text/x-java"
    "text/x-kotlin"
    "text/x-lua"
    "text/x-makefile"
    "text/x-python"
    "text/x-python3"
    "text/x-tex"
    "text/xml"
    "text/x-yaml"
    "text/yaml"
  ] (_: "nvim.desktop");
}
