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
        shown_boxes = "cpu mem net proc gpu0";
        shown_gpus = "amd";
        show_gpu_info = "On";
      }
    else
      { };

in
{
  programs.btop = {
    enable = true;
    package = if host.gpu.hasNvidia then pkgs.btop.override { cudaSupport = true; } else pkgs.btop;
    settings = baseSettings // gpuSettings;
  };
}
