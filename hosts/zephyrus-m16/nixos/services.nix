{ lib, ... }:

{
  services = {
    tlp = {
      enable = true;
      settings = {
        PLATFORM_PROFILE_ON_AC = "";
        PLATFORM_PROFILE_ON_BAT = "";
        PLATFORM_PROFILE_ON_SAV = "";
        CPU_ENERGY_PERF_POLICY_ON_AC = "";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "";
        START_CHARGE_THRESH_BAT0 = lib.mkForce 0;
        STOP_CHARGE_THRESH_BAT0 = lib.mkForce 80;
        USB_DENYLIST = "04e8:6860";
      };
    };
    asusd = {
      enable = true;

      asusdConfig.text = ''
        (
            charge_control_end_threshold: 80,
            base_charge_control_end_threshold: 80,
            disable_nvidia_powerd_on_battery: true,
            ac_command: "",
            bat_command: "",
            platform_profile_linked_epp: true,
            platform_profile_on_battery: Quiet,
            change_platform_profile_on_battery: true,
            platform_profile_on_ac: Balanced,
            change_platform_profile_on_ac: true,
            profile_quiet_epp: Power,
            profile_balanced_epp: BalancePower,
            profile_custom_epp: Performance,
            profile_performance_epp: Performance,
            ac_profile_tunings: {},
            dc_profile_tunings: {},
            armoury_settings: {},
        )
      '';

      fanCurvesConfig.text = ''
        (
            profiles: (
                balanced: [
                    (
                        fan: CPU,
                        pwm: (2, 33, 56, 89, 122, 132, 175, 175),
                        temp: (55, 58, 61, 64, 67, 69, 71, 71),
                        enabled: false,
                    ),
                    (
                        fan: GPU,
                        pwm: (2, 45, 56, 89, 132, 142, 188, 188),
                        temp: (55, 58, 61, 64, 67, 69, 71, 71),
                        enabled: false,
                    ),
                ],
                performance: [
                    (
                        fan: CPU,
                        pwm: (56, 89, 122, 165, 198, 255, 255, 255),
                        temp: (35, 58, 61, 64, 67, 70, 70, 70),
                        enabled: false,
                    ),
                    (
                        fan: GPU,
                        pwm: (56, 89, 132, 165, 209, 255, 255, 255),
                        temp: (35, 58, 61, 64, 67, 70, 70, 70),
                        enabled: false,
                    ),
                ],
                quiet: [
                    (
                        fan: CPU,
                        pwm: (2, 12, 33, 56, 66, 89, 89, 89),
                        temp: (55, 58, 61, 65, 69, 73, 73, 73),
                        enabled: false,
                    ),
                    (
                        fan: GPU,
                        pwm: (2, 12, 45, 56, 79, 89, 89, 89),
                        temp: (55, 58, 61, 65, 69, 73, 73, 73),
                        enabled: false,
                    ),
                ],
                custom: [],
            ),
        )
      '';

      auraConfigs."19b6".text = ''
        (
            config_name: "aura_19b6.ron",
            brightness: Med,
            current_mode: Static,
            builtins: {
                Static: (
                    mode: Static,
                    zone: r#None,
                    colour1: (
                        r: 166,
                        g: 0,
                        b: 0,
                    ),
                    colour2: (
                        r: 0,
                        g: 0,
                        b: 0,
                    ),
                    speed: Med,
                    direction: Right,
                ),
                Breathe: (
                    mode: Breathe,
                    zone: r#None,
                    colour1: (
                        r: 166,
                        g: 0,
                        b: 0,
                    ),
                    colour2: (
                        r: 0,
                        g: 0,
                        b: 0,
                    ),
                    speed: Med,
                    direction: Right,
                ),
                RainbowCycle: (
                    mode: RainbowCycle,
                    zone: r#None,
                    colour1: (
                        r: 166,
                        g: 0,
                        b: 0,
                    ),
                    colour2: (
                        r: 0,
                        g: 0,
                        b: 0,
                    ),
                    speed: Med,
                    direction: Right,
                ),
                RainbowWave: (
                    mode: RainbowWave,
                    zone: r#None,
                    colour1: (
                        r: 166,
                        g: 0,
                        b: 0,
                    ),
                    colour2: (
                        r: 0,
                        g: 0,
                        b: 0,
                    ),
                    speed: Med,
                    direction: Right,
                ),
                Pulse: (
                    mode: Pulse,
                    zone: r#None,
                    colour1: (
                        r: 166,
                        g: 0,
                        b: 0,
                    ),
                    colour2: (
                        r: 0,
                        g: 0,
                        b: 0,
                    ),
                    speed: Med,
                    direction: Right,
                ),
            },
            multizone_on: false,
            enabled: (
                states: [
                    (
                        zone: Keyboard,
                        boot: true,
                        awake: true,
                        sleep: true,
                        shutdown: true,
                    ),
                ],
            ),
        )
      '';
    };
    supergfxd.enable = lib.mkDefault true;
  };
}
