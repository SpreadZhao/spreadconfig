{ pkgs, repoLink, ... }:

{
  home.packages = [ pkgs.jetbrains-toolbox ];

  home.file.".ideavimrc".source = repoLink "modules/home/jetbrains-toolbox/files/.ideavimrc";
}
