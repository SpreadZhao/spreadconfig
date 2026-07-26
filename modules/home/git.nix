{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "SpreadZhao";
        email = "spreadzhao@outlook.com";
      };
      pull.rebase = true;
      rebase.autoStash = true;
      credential = {
        "https://github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
        "https://gist.github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
      };
      diff.gpg = {
        textconv = "${pkgs.gnupg}/bin/gpg --quiet --no-tty --decrypt";
        cachetextconv = false;
      };
    };
  };
}
