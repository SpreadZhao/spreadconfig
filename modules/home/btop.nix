{
  hostName,
  pkgs,
  ...
}:

let
  baseSettings = {
    theme_background = false;
    truecolor = true;
    vim_keys = true;
  };

  gpuSettingsByHost = {
    thinkbook = {
      shown_gpus = "amd";
    };

    zephyrus-m16 = {
      shown_boxes = "cpu mem net proc gpu0";
      shown_gpus = "nvidia";
      show_gpu_info = "On";
    };
  };

  nvidiaBtop = pkgs.symlinkJoin {
    name = "btop-nvidia";
    paths = [ pkgs.btop ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/btop \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
    '';
  };

  hostGpuSettings = gpuSettingsByHost.${hostName} or { };
in
{
  programs.btop = {
    enable = true;
    package = if hostName == "zephyrus-m16" then nvidiaBtop else pkgs.btop;
    settings = baseSettings // hostGpuSettings;
  };
}
