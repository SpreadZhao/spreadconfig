{ lib, ... }:

{
  imports = [ ./scripts.nix ];

  nix.gc.automatic = false;
  services.home-manager.autoExpire.enable = false;

  home.sessionPath = lib.mkOrder 300 [ "$SCRIPT_HOME/nix" ];
}
