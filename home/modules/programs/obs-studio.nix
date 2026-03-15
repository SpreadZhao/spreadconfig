{ pkgs-old-dd9b079, ... }:

{
    programs.obs-studio = {
        enable = true;
        plugins = with pkgs-old-dd9b079.obs-studio-plugins; [
            obs-backgroundremoval
            obs-pipewire-audio-capture
            obs-vaapi
        ];
    };
}
