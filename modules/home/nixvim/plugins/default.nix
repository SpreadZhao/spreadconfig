{ pkgs, ... }: {
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
      src = pkgs.fetchFromGitHub {
        owner = "fei6409";
        repo = "log-highlight.nvim";
        rev = "v1.2.1";
        hash = "sha256-jNmoWrF5xvRbD2ujezyeBmvU1Z7hLg981hVL5HA4pZk=";
      };
    })
    pkgs.vimPlugins.outline-nvim
    pkgs.vimPlugins.quick-scope
  ];
}
