{ lib, pkgs, ... }:
let
  editorMimeTypes = [
    "application/json"
    "application/schema+json"
    "application/sql"
    "application/toml"
    "application/x-ndjson"
    "application/x-shellscript"
    "application/xml"
    "application/yaml"
    "inode/x-empty"
    "text/css"
    "text/english"
    "text/javascript"
    "text/markdown"
    "text/plain"
    "text/rust"
    "text/vnd.trolltech.linguist"
    "text/x-asm"
    "text/x-awk"
    "text/x-c"
    "text/x-c++"
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-cmake"
    "text/x-csrc"
    "text/x-diff"
    "text/x-gawk"
    "text/x-go"
    "text/x-java"
    "text/x-kotlin"
    "text/x-lisp"
    "text/x-lua"
    "text/x-m4"
    "text/x-makefile"
    "text/x-moc"
    "text/x-msdos-batch"
    "text/x-nawk"
    "text/x-objective-c"
    "text/x-pascal"
    "text/x-perl"
    "text/x-php"
    "text/x-po"
    "text/x-python"
    "text/x-python3"
    "text/x-ruby"
    "text/x-script.python"
    "text/x-shellscript"
    "text/x-tcl"
    "text/x-tex"
    "text/x-yaml"
    "text/xml"
    "text/yaml"
  ];

  nvimDesktopLaunch = pkgs.writeShellScript "nvim-desktop-launch" ''
    nvim_opts=()
    nvim_files=()
    for arg in "$@"; do
      line=""
      path="$arg"
      if [[ "$path" == file://* ]]; then
        path="''${path#file://localhost}"
        path="''${path#file://"$HOSTNAME"}"
        path="''${path#file://}"
        if [[ "$path" == *#* ]]; then
          fragment="''${path#*#}"
          path="''${path%%#*}"
          if [[ "$fragment" =~ ^[Ll]?([0-9]+) ]]; then
            line="''${BASH_REMATCH[1]}"
          fi
        fi
        path="''${path%%\?*}"
        path="''${path//\\/\\\\}"
        printf -v path '%b' "''${path//%/\\x}"
      fi
      if [[ -n "$line" ]]; then
        nvim_opts+=("+$line")
      fi
      nvim_files+=("$path")
    done

    if ((''${#nvim_files[@]} > 0)); then
      exec footclient -a nvim -T nvim -- nvim "''${nvim_opts[@]}" -- "''${nvim_files[@]}"
    else
      exec footclient -a nvim -T nvim -- nvim
    fi
  '';
in
{
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

  xdg = {
    desktopEntries.nvim = {
      name = "Neovim wrapper";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "${nvimDesktopLaunch} %U";
      icon = "nvim";
      terminal = false;
      type = "Application";
      categories = [
        "Utility"
        "TextEditor"
        "Development"
      ];
      mimeType = editorMimeTypes;
      startupNotify = false;
      settings = {
        Keywords = "Text;editor;";
        TryExec = "nvim";
      };
    };

    mimeApps.defaultApplications = lib.genAttrs editorMimeTypes (_: "nvim.desktop");
  };
}
