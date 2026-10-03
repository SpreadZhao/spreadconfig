{ pkgs, ... }:

{
  imports = [ ./scripts.nix ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "SpreadZhao";
        email = "spreadzhao@outlook.com";
      };
      pull.rebase = true;
      rebase.autoStash = true;
      diff.gpg = {
        textconv = "${pkgs.gnupg}/bin/gpg --quiet --no-tty --decrypt";
        cachetextconv = false;
      };
    };
  };
}
