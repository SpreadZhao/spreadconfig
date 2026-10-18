{ ... }: {
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

}
