{
  hostConfigSource,
  pkgs,
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

  xdg.configFile."obs-studio/basic/profiles/Video".source = hostConfigSource "obs/profiles/Video";
  xdg.configFile."obs-studio/basic/profiles/Audio".source = hostConfigSource "obs/profiles/Audio";
}
