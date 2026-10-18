{ pkgs, ... }:

# Evaluate this body at the legacy top-level position rather than adding a
# nested module, preserving home.packages and Fontconfig directory order.
import ./drawio/mime.nix { inherit pkgs; }
