{ ... }:
let
  vscodeColors = import ./palette.nix;
in
{
  highlightOverride = {
    LineNrAbove.fg = vscodeColors.lineNumber;
    LineNrBelow.fg = vscodeColors.lineNumber;
  };
  colorscheme = "vscode";
  colorschemes = {
    vscode = {
      enable = true;
      settings = {
        transparent = true;
        italic_comments = false; # Match the JetBrains comment style.
        italic_inlayhints = true;
        underline_links = true;
        disable_nvimtree_bg = true;
        terminal_colors = true;

        color_overrides = {
          vscBack = vscodeColors.back;
          vscLineNumber = vscodeColors.lineNumberDark;
          vscCursorDarkDark = vscodeColors.cursorDarkDark;
          vscSelection = vscodeColors.selection;
          vscForeground = vscodeColors.foreground;
        };

        group_overrides = {
          # Comments
          Comment = {
            fg = vscodeColors.comment;
            italic = false;
          };

          # Keywords
          Keyword = {
            fg = vscodeColors.keyword;
          };

          # Static members
          StorageClass = {
            fg = vscodeColors.static;
          };

          # Types
          Type = {
            fg = vscodeColors.type;
          };

          # Members
          Field = {
            fg = vscodeColors.type;
          };

          Property = {
            fg = vscodeColors.type;
          };

          # Functions
          Function = {
            fg = vscodeColors.function;
          };

          # Errors
          DiagnosticError = {
            fg = vscodeColors.error;
            bold = true;
          };

          # Strings
          String = {
            fg = vscodeColors.string;
          };

          # Constants
          Constant = {
            fg = vscodeColors.static;
          };
        };
      };
    };
  };

}
