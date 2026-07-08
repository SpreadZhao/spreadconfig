{ ... }:

{
  services.pipewire.wireplumber.extraConfig."51-zephyrus-m16-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "device.name" = "alsa_card.pci-0000_00_1f.3";
          }
        ];
        actions."update-props" = {
          "device.profile" = "output:analog-stereo+input:analog-stereo";
          "session.dont-restore-off-profile" = true;
        };
      }
    ];
  };
}
