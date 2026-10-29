{
  lib,
  pkgs,
  utils,
  ...
}:

let
  bindings = import ../gaomon-bindings.nix;
  hasBindings = lib.any (action: action != null) (lib.attrValues bindings);
  deviceName = "GAOMON M5 V2 Pen";
  devicePath = "/dev/input/by-id/usb-GAOMON_M5_V2-if02-event-kbd";
  presetName = "gaomon-m5";
  bindingsHash = builtins.hashString "sha256" (builtins.toJSON bindings);

in
{
  services.input-remapper = {
    enable = true;
    enableUdevRules = false;
  };

  services.udev.extraRules = lib.optionalString hasBindings ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_VENDOR_ID}=="256c", ENV{ID_MODEL_ID}=="200e", ENV{ID_USB_INTERFACE_NUM}=="02", ENV{ID_INPUT_KEYBOARD}=="1", TAG+="systemd", ENV{SYSTEMD_WANTS}+="gaomon-input-remapper.service"
  '';

  systemd.services.gaomon-input-remapper = lib.mkIf hasBindings {
    description = "Load the GAOMON M5 input-remapper preset";
    wantedBy = [ "graphical.target" ];
    after = [ "input-remapper.service" ];
    wants = [ "input-remapper.service" ];
    unitConfig.ConditionPathExists = devicePath;
    restartTriggers = [ bindingsHash ];
    environment = {
      USER = "spreadzhao";
      HOME = "/home/spreadzhao";
      XDG_CONFIG_HOME = "/home/spreadzhao/.config";
    };
    serviceConfig = {
      Type = "oneshot";
      # Ignore loader failures so an unavailable tablet cannot block activation.
      ExecStart = "-${
        utils.escapeSystemdExecArgs [
          "${pkgs.input-remapper}/bin/input-remapper-control"
          "--command"
          "start"
          "--device"
          deviceName
          "--preset"
          presetName
          "--config-dir"
          "/home/spreadzhao/.config/input-remapper-2"
        ]
      }";
    };
  };
}
