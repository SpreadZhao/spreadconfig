{ lib, ... }:

{
  fileSystems = {
    "/home/spreadzhao/mnt/dav" = {
      enable = false;
      device = "${lib.strings.trim (builtins.readFile ../../secrets/nas_url)}";
      fsType = "davfs";
      options = [
        "_netdev"
        "user"
        "noauto"
      ];
    };
  };
}
