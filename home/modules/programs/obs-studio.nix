{
  pkgs,
  config,
  spreadconfigDir,
  ...
}:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
    ];
  };

  xdg.configFile."obs-studio/basic/profiles/Video".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/obs/profiles/Video";
  xdg.configFile."obs-studio/basic/profiles/Audio".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/obs/profiles/Audio";
}
