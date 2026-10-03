{
  host,
  pkgs,
  ...
}:

{
  programs.obs-studio = {
    enable = true;
    plugins = map (name: pkgs.obs-studio-plugins.${name}) host.profile.home.obs.plugins;
  };

}
