{ ... }:

{
  # Keep authentication windows on Intel without affecting other GPUI apps.
  systemd.user.services = {
    gpg-agent.Service.Environment = [ "ZED_DEVICE_ID=46a6" ];
    psst-polkit-agent.Service.Environment = [ "ZED_DEVICE_ID=46a6" ];
  };
}
