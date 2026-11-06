{
  host,
  pkgs,
  ...
}:

{
  programs.btop = {
    enable = true;
    package = if host.gpu.hasNvidia then pkgs.btop.override { cudaSupport = true; } else pkgs.btop;
    settings = {
      theme_background = false;
      truecolor = true;
      vim_keys = true;
    }
    // (
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
        { }
    );
  };
}
