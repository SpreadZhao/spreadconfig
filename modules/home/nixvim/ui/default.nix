{ ... }: {
  imports = [
    ./colors.nix
    ./statusline.nix
  ];
  plugins.web-devicons.enable = true;
  plugins.fidget = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.event = "VimEnter";
    };
  };
}
