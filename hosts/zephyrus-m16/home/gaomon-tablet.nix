{ lib, pkgs, ... }:

let
  bindings = import ../gaomon-bindings.nix;
  deviceName = "GAOMON M5 V2 Pen";
  presetName = "gaomon-m5";

  key = code: {
    type = 1;
    inherit code;
  };

  inputCombinations = {
    pad1Top = map key [
      29 # KEY_LEFTCTRL
      56 # KEY_LEFTALT
      44 # KEY_Z
    ];
    pad2 = [ (key 23) ]; # KEY_I
    pad3 = [ (key 26) ]; # KEY_LEFTBRACE
    pad4 = [ (key 27) ]; # KEY_RIGHTBRACE
    pad5 = [ (key 57) ]; # KEY_SPACE
    pad6 = map key [
      29 # KEY_LEFTCTRL
      31 # KEY_S
    ];
    pad7 = map key [
      29 # KEY_LEFTCTRL
      78 # KEY_KPPLUS
    ];
    pad8Bottom = map key [
      29 # KEY_LEFTCTRL
      74 # KEY_KPMINUS
    ];
  };

  configuredBindings = lib.filterAttrs (_: action: action != null) bindings;
  mappings = lib.mapAttrsToList (name: action: {
    input_combination = inputCombinations.${name};
    target_uinput = "keyboard";
    output_symbol = action;
  }) configuredBindings;
in
{
  assertions = [
    {
      assertion = builtins.attrNames bindings == builtins.attrNames inputCombinations;
      message = "GAOMON bindings and input combinations must define the same buttons";
    }
    {
      assertion = lib.all (action: action == null || (builtins.isString action && action != "")) (
        lib.attrValues bindings
      );
      message = "GAOMON bindings must be null or a non-empty input-remapper output string";
    }
  ];

  xdg.configFile = {
    "input-remapper-2/config.json".text = builtins.toJSON {
      version = pkgs.input-remapper.version;
      autoload = { };
    };

    # Bindings use Linux evdev names, so no session-specific X11 symbols are needed.
    "input-remapper-2/xmodmap.json".text = "{}";

    "input-remapper-2/presets/${deviceName}/${presetName}.json".text = builtins.toJSON mappings;
  };
}
