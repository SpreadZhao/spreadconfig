logHighlightSrc:
{ pkgs, ... }:
{
  imports = [
    ./completion.nix
    ./editing.nix
    ./git.nix
    ./navigation.nix
    ./formatting.nix
    ./media.nix
  ];
  plugins.lz-n = {
    enable = true;
    autoLoad = true;
  };
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "log-highlight";
      src = logHighlightSrc;
    })
    pkgs.vimPlugins.outline-nvim
    pkgs.vimPlugins.quick-scope
  ];
}
