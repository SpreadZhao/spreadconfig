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
        italic_comments = false; # JetBrains 默认不斜体
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
          # ===== 注释 =====
          Comment = {
            fg = vscodeColors.comment;
            italic = false;
          };

          # ===== 关键字 =====
          Keyword = {
            fg = vscodeColors.keyword;
          };

          # ===== static =====
          StorageClass = {
            fg = vscodeColors.static;
          };

          # ===== 类 =====
          Type = {
            fg = vscodeColors.type;
          };

          # ===== 类成员 =====
          Field = {
            fg = vscodeColors.type;
          };

          Property = {
            fg = vscodeColors.type;
          };

          # ===== 函数 =====
          Function = {
            fg = vscodeColors.function;
          };

          # ===== 错误 =====
          DiagnosticError = {
            fg = vscodeColors.error;
            bold = true;
          };

          # ===== 字符串 =====
          String = {
            fg = vscodeColors.string;
          };

          # ===== 常量 =====
          Constant = {
            fg = vscodeColors.static;
          };
        };
      };
    };
  };

}
