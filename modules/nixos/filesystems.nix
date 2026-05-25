{ ... }:

{
  fileSystems = {
    "/home/spreadzhao/mnt/dav" = {
      enable = false;
      device = "https://example.invalid";
      fsType = "davfs";
      options = [
        "_netdev"
        "user"
        "noauto"
      ];
    };
  };
}
