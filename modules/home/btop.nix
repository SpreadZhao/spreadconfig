{
  host,
  pkgs,
  ...
}:

let
  baseSettings = {
    theme_background = false;
    truecolor = true;
    vim_keys = true;
  };

  gpuSettings =
    if host.gpu.hasNvidia then
      {
        shown_boxes = "cpu mem net proc gpu0";
        shown_gpus = "nvidia";
        show_gpu_info = "On";
      }
    else if host.gpu.hasAmd then
      {
        shown_gpus = "amd";
      }
    else
      { };

  nvidiaBtop = pkgs.symlinkJoin {
    name = "btop-nvidia";
    paths = [ pkgs.btop ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/btop \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
    '';
  };
in
{
  programs.btop = {
    enable = true;
    package = if host.gpu.hasNvidia then nvidiaBtop else pkgs.btop;
    settings = baseSettings // gpuSettings;
  };
}
