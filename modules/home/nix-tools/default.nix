{ lib, ... }:

{
  imports = [ ./scripts.nix ];

  home.sessionPath = lib.mkOrder 300 [ "$SCRIPT_HOME/nix" ];
}
