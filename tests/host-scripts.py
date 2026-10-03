#!/usr/bin/env python3
"""Exercise host-aware scripts using temporary profiles, sysfs and command mocks."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
HOSTS = ("desktop1", "thinkbook", "zephyrus-m16", "amd-desktop")
SCRIPT_OWNERS = {
    "config/host_context.sh": "script-tools",
    "config/preview_file.sh": "script-tools",
    "config/fzf_preview.sh": "fzf",
    "niri/fzf_dmenu_preview.sh": "niri",
    "nix/sns": "nix-tools",
    "nix/sns_until": "nix-tools",
    "nix/nix_update": "nix-tools",
    "nix/nix_update.exclude": "nix-tools",
    "util/get_battery.sh": "waybar",
    "util/get_brightness.sh": "waybar",
    "util/camera.sh": "mpv",
}
MOCK_COMMAND = '''#!/usr/bin/env python3
import json
import os
from pathlib import Path
import sys
name = Path(sys.argv[0]).name
log = Path(os.environ["MOCK_LOG"])
previous = log.read_text().splitlines() if log.exists() else []
with log.open("a") as stream:
    stream.write(json.dumps([name, *sys.argv[1:]]) + "\\n")
if name == "nh":
    attempt = 1 + sum(json.loads(line)[0] == "nh" for line in previous)
    sys.exit(1 if attempt <= int(os.environ.get("MOCK_NH_FAILURES", "0")) else 0)
elif name == "hostname":
    print(os.environ.get("MOCK_HOSTNAME", "desktop1"))
elif name == "brightnessctl":
    print(os.environ.get("MOCK_BRIGHTNESS", "intel_backlight,backlight,50,50%,100"))
    sys.exit(int(os.environ.get("MOCK_BRIGHTNESS_EXIT", "0")))
elif name == "nix":
    if sys.argv[1] == "eval":
        flake = os.environ.get("SPREADCONFIG_FLAKE_FILE", "")
        if not Path(flake).is_file() or flake != os.environ["MOCK_EXPECTED_FLAKE_FILE"]:
            print("mock nix: unexpected flake file: " + flake, file=sys.stderr)
            sys.exit(10)
        print(os.environ.get("MOCK_FLAKE_INPUTS", '["nixpkgs", "home-manager", "textbridge"]'))
    elif sys.argv[1:3] == ["flake", "update"]:
        attempt = 1 + sum(json.loads(line)[:3] == ["nix", "flake", "update"] for line in previous)
        if attempt <= int(os.environ.get("MOCK_NIX_WARNINGS", "0")):
            print("warning: Connection timed out", file=sys.stderr)
        sys.exit(1 if attempt <= int(os.environ.get("MOCK_NIX_FAILURES", "0")) else 0)
    else:
        print("mock nix: unsupported invocation", file=sys.stderr)
        sys.exit(11)
elif name == "cliphist":
    print("clipboard text")
'''


class HostScripts(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="spreadconfig-host-scripts-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "checkout with spaces"
        self.entrypoints = self.repo / "test-entrypoints"
        self.forwarded = self.entrypoints / "default"
        self.sources = {}
        for rel, owner in SCRIPT_OWNERS.items():
            source = Path("modules/home") / owner / "scripts" / rel
            target = self.repo / source
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / source, target)
            self.sources[rel] = target
            forwarded = self.forwarded / rel
            forwarded.parent.mkdir(parents=True, exist_ok=True)
            forwarded.symlink_to(os.path.relpath(target, forwarded.parent))
        (self.repo / "flake.nix").write_text("{ inputs = {}; }\n")
        preview = self.sources["config/preview_file.sh"]
        preview.write_text(MOCK_COMMAND)
        preview.chmod(0o755)
        resolver_rel = Path("skills/local/spreadconfig-nix/scripts/resolve-nix-script")
        self.resolver = self.repo / resolver_rel
        self.resolver.parent.mkdir(parents=True)
        shutil.copy2(ROOT / resolver_rel, self.resolver)
        for name in HOSTS:
            target = self.repo / "hosts" / name / "host.nix"
            target.parent.mkdir(parents=True)
            target.write_text("{}\n")
            for script in ("sns", "sns_until"):
                forwarded = self.entrypoints / "hosts" / name / "nix" / script
                forwarded.parent.mkdir(parents=True, exist_ok=True)
                forwarded.symlink_to(f"../../../default/nix/{script}")
        self.context = self.root / "config/spreadconfig/host.sh"
        self.context.parent.mkdir(parents=True)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for name in ("nh", "hostname", "sleep", "mpv", "brightnessctl", "nix", "sns_until", "cliphist"):
            target = self.bin / name
            target.write_text(MOCK_COMMAND)
            target.chmod(0o755)
        self.log = self.root / "commands.jsonl"
        self.env = {
            key: value
            for key, value in os.environ.items()
            if not key.startswith(("SPREADCONFIG_", "NIX_RETRY_", "MOCK_"))
            and key not in ("SCRIPT_HOME", "KITTY_WINDOW_ID")
        }
        self.env.update(
            HOME=str(self.root / "home"),
            XDG_CONFIG_HOME=str(self.context.parents[1]),
            PATH=f"{self.bin}:{os.environ['PATH']}",
            MOCK_LOG=str(self.log),
            MOCK_EXPECTED_FLAKE_FILE=str(self.repo / "flake.nix"),
            SPREADCONFIG_POWER_SUPPLY_ROOT=str(self.root / "power_supply"),
        )

    def profile(self, **values):
        import shlex

        self.context.write_text(
            "".join(f"{name}={shlex.quote(str(value))}\n" for name, value in values.items())
        )

    def run_script(self, script, *args, **env):
        return self.run_entrypoint(self.sources[script], *args, **env)

    def run_entrypoint(self, entrypoint, *args, **env):
        return subprocess.run(
            ["bash", str(entrypoint), *args],
            env={**self.env, **env},
            text=True,
            capture_output=True,
            timeout=10,
        )

    def calls(self, command):
        lines = self.log.read_text().splitlines() if self.log.exists() else []
        return [call[1:] for line in lines if (call := json.loads(line))[0] == command]

    def battery(self, capacity="42", status="Discharging"):
        target = self.root / "devices/BAT1"
        target.mkdir(parents=True, exist_ok=True)
        for name, value in {"type": "Battery", "capacity": capacity, "status": status}.items():
            (target / name).write_text(value + "\n")
        supply = self.root / "power_supply"
        supply.mkdir(exist_ok=True)
        (supply / "BAT1").symlink_to(target)
        return target

    def test_all_configured_hosts_and_actions(self):
        for host in HOSTS:
            for args, action in (((), "switch"), (("boot",), "boot")):
                with self.subTest(host=host, action=action):
                    self.profile(
                        SPREADCONFIG_CONFIGURED_HOST=host,
                        SPREADCONFIG_CONFIGURED_REPO=self.repo,
                    )
                    result = self.run_script("nix/sns", *args)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(
                        self.calls("nh")[-1],
                        ["os", action, "-d", "always", "-t", f"path://{self.repo}#{host}"],
                    )
        self.assertEqual(self.calls("hostname"), [])

    def test_explicit_overrides_configured_host_and_repo(self):
        self.profile(SPREADCONFIG_CONFIGURED_HOST="unknown", SPREADCONFIG_CONFIGURED_REPO="/missing")
        result = self.run_script(
            "nix/sns", SPREADCONFIG_HOST="thinkbook", SPREADCONFIG_REPO=str(self.repo)
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("nh")[-1][-1], f"path://{self.repo}#thinkbook")

    def test_bootstrap_uses_checkout_and_hostname(self):
        result = self.run_script("nix/sns", MOCK_HOSTNAME="amd-desktop")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("nh")[-1][-1], f"path://{self.repo}#amd-desktop")

    def test_forwarded_entrypoints_resolve_module_sources(self):
        for script in ("sns", "sns_until"):
            result = self.run_entrypoint(self.forwarded / "nix" / script, "boot")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.calls("nh")[-1][-1], f"path://{self.repo}#desktop1")

    def test_installed_symlink_tree_resolves_checkout(self):
        installed = self.root / "installed-scripts"
        for rel in SCRIPT_OWNERS:
            target = installed / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.symlink_to(self.sources[rel])
        result = subprocess.run(
            ["bash", str(installed / "nix/sns")],
            env=self.env,
            text=True,
            capture_output=True,
            timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("nh")[-1][-1], f"path://{self.repo}#desktop1")

    def test_forwarded_host_entrypoints_work_without_installed_helper(self):
        installed = self.root / "forwarded-installed-scripts/nix"
        installed.mkdir(parents=True)
        for host in HOSTS:
            for script in ("sns", "sns_until"):
                entrypoint = installed / script
                entrypoint.unlink(missing_ok=True)
                entrypoint.symlink_to(self.entrypoints / "hosts" / host / "nix" / script)
                result = subprocess.run(
                    ["bash", str(entrypoint), "boot"],
                    env={**self.env, "MOCK_HOSTNAME": host},
                    text=True,
                    capture_output=True,
                    timeout=10,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    self.calls("nh")[-1],
                    ["os", "boot", "-d", "always", "-t", f"path://{self.repo}#{host}"],
                )
        self.assertFalse((installed.parent / "config/host_context.sh").exists())

    def test_forwarded_device_scripts_work_without_installed_helper(self):
        self.battery()
        installed = self.root / "forwarded-installed-scripts/util"
        installed.mkdir(parents=True)
        for script, expected in (("get_battery.sh", "42󰁽\n"), ("get_brightness.sh", "50󱩎\n")):
            entrypoint = installed / script
            entrypoint.symlink_to(self.forwarded / "util" / script)
            result = subprocess.run(
                ["bash", str(entrypoint)], env=self.env, text=True, capture_output=True, timeout=10
            )
            self.assertEqual((result.returncode, result.stdout, result.stderr), (0, expected, ""))
        self.assertFalse((installed.parent / "config/host_context.sh").exists())

    def test_invalid_host_or_action_never_calls_nh(self):
        for host in ("unknown", "../desktop1", "desktop1/anything"):
            result = self.run_script("nix/sns", SPREADCONFIG_HOST=host)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unknown host", result.stderr)
        self.assertNotEqual(self.run_script("nix/sns", "test").returncode, 0)
        self.assertEqual(self.calls("nh"), [])

    def test_bootstrap_fails_without_checkout_marker(self):
        (self.repo / "flake.nix").unlink()
        result = self.run_script("nix/sns")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("could not find source checkout", result.stderr)
        self.assertEqual(self.calls("nh"), [])

    def test_retry_succeeds_within_default_attempts(self):
        result = self.run_script("nix/sns_until", "boot", MOCK_NH_FAILURES="2")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls("nh")), 3)
        self.assertEqual(self.calls("sleep"), [["1"], ["1"]])
        self.assertTrue(all(call[1] == "boot" for call in self.calls("nh")))

    def test_retry_stops_at_configured_limit(self):
        result = self.run_script(
            "nix/sns_until", MOCK_NH_FAILURES="9", NIX_RETRY_ATTEMPTS="2", NIX_RETRY_DELAY="0"
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(self.calls("nh")), 2)
        self.assertEqual(self.calls("sleep"), [["0"]])

    def test_retry_success_does_not_sleep(self):
        result = self.run_script("nix/sns_until")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls("nh")), 1)
        self.assertEqual(self.calls("sleep"), [])

    def test_invalid_retry_parameters_never_call_nh(self):
        for value in ("0", "abc", "-1"):
            self.assertNotEqual(
                self.run_script("nix/sns_until", NIX_RETRY_ATTEMPTS=value).returncode, 0
            )
        self.assertNotEqual(self.run_script("nix/sns_until", NIX_RETRY_DELAY="bad").returncode, 0)
        self.assertEqual(self.calls("nh"), [])

    def test_battery_enumerates_sysfs_symlinks(self):
        self.battery()
        result = self.run_script("util/get_battery.sh")
        self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "42󰁽\n", ""))

    def test_battery_explicit_device_name_and_absolute_path(self):
        target = self.battery(capacity="8", status="Charging")
        for device in ("BAT1", str(target)):
            self.profile(SPREADCONFIG_BATTERY_DEVICE=device)
            result = self.run_script("util/get_battery.sh")
            self.assertEqual((result.returncode, result.stdout), (0, "8󰂄\n"))

    def test_battery_absent_disabled_missing_or_invalid_is_quiet(self):
        self.assertEqual(self.run_script("util/get_battery.sh").stdout, "")
        self.battery(capacity="bad")
        for values in ({}, {"SPREADCONFIG_HAS_BATTERY": "false"}, {"SPREADCONFIG_BATTERY_DEVICE": "BAT2"}):
            self.profile(**values)
            result = self.run_script("util/get_battery.sh")
            self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))

    def test_brightness_auto_and_explicit_device(self):
        for device, expected in (("", ["-m"]), ("/sys/class/backlight/intel_backlight", ["-m", "--device", "intel_backlight"])):
            self.profile(SPREADCONFIG_BACKLIGHT_DEVICE=device)
            result = self.run_script("util/get_brightness.sh")
            self.assertEqual((result.returncode, result.stdout), (0, "50󱩎\n"))
            self.assertEqual(self.calls("brightnessctl")[-1], expected)

    def test_brightness_disabled_never_calls_brightnessctl(self):
        self.profile(SPREADCONFIG_HAS_BACKLIGHT="false")
        result = self.run_script("util/get_brightness.sh")
        self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))
        self.assertEqual(self.calls("brightnessctl"), [])

    def test_brightness_unavailable_is_quiet(self):
        result = self.run_script("util/get_brightness.sh", MOCK_BRIGHTNESS_EXIT="1")
        self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))

    def test_camera_missing_device_is_clear(self):
        self.profile(SPREADCONFIG_CAMERA_DEVICE=self.root / "missing-camera")
        result = self.run_script("util/camera.sh")
        self.assertEqual(result.returncode, 1)
        self.assertIn("no camera device available", result.stderr)
        self.assertEqual(self.calls("mpv"), [])

    def test_camera_forwards_arguments(self):
        self.profile(SPREADCONFIG_CAMERA_DEVICE="/dev/null")
        result = self.run_script("util/camera.sh", "--title=Camera view", "--no-audio")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("mpv"), [["/dev/null", "--title=Camera view", "--no-audio"]])

    def test_shared_preview_from_source_forwarded_and_installed_entrypoints(self):
        installed = self.root / "installed-scripts/config/fzf_preview.sh"
        installed.parent.mkdir(parents=True)
        installed.symlink_to(self.forwarded / "config/fzf_preview.sh")
        for entrypoint in (
            self.sources["config/fzf_preview.sh"],
            self.forwarded / "config/fzf_preview.sh",
            installed,
        ):
            result = self.run_entrypoint(entrypoint, "file with spaces.txt", "100", "30")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.calls("preview_file.sh")[-1], ["file with spaces.txt", "100", "30"])

    def test_niri_preview_finds_shared_helper_from_source_and_forwarded_link(self):
        for entrypoint in (
            self.sources["niri/fzf_dmenu_preview.sh"],
            self.forwarded / "niri/fzf_dmenu_preview.sh",
        ):
            result = self.run_entrypoint(entrypoint, "42 clipboard text")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.calls("cliphist")[-1], ["decode", "42"])
            self.assertEqual(self.calls("preview_file.sh")[-1][1:], ["80", "24"])

    def test_nix_update_list_inputs_handles_spaces_and_forwarded_links(self):
        for entrypoint in (self.sources["nix/nix_update"], self.forwarded / "nix/nix_update"):
            result = self.run_entrypoint(entrypoint, "--list-inputs")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.splitlines(), ["nixpkgs", "home-manager", "textbridge"])
        self.assertEqual(self.calls("sns_until"), [])
        self.assertTrue(all(call[0] == "eval" for call in self.calls("nix")))

    def test_nix_update_respects_explicit_repo_and_excludes(self):
        target = self.root / "other checkout with spaces"
        target.mkdir()
        (target / "flake.nix").write_text("{ inputs = {}; }\n")
        result = self.run_script(
            "nix/nix_update", "switch", "--no-exclude-file", "--exclude", "textbridge",
            SPREADCONFIG_REPO=str(target), MOCK_EXPECTED_FLAKE_FILE=str(target / "flake.nix"),
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.calls("nix")[-1],
            ["flake", "update", "--flake", f"path://{target}", "nixpkgs", "home-manager"],
        )
        self.assertEqual(self.calls("sns_until"), [["switch"]])

    def test_nix_update_reads_adjacent_default_exclude_file(self):
        self.sources["nix/nix_update.exclude"].write_text("textbridge\n")
        result = self.run_script("nix/nix_update")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("nix")[-1][-2:], ["nixpkgs", "home-manager"])
        self.assertEqual(self.calls("sns_until"), [["boot"]])

    def test_nix_update_retries_mock_failures_and_warnings(self):
        result = self.run_script(
            "nix/nix_update", "--no-exclude-file", MOCK_NIX_FAILURES="1", MOCK_NIX_WARNINGS="2",
            NIX_RETRY_ATTEMPTS="3", NIX_RETRY_DELAY="0",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        updates = [call for call in self.calls("nix") if call[:2] == ["flake", "update"]]
        self.assertEqual(len(updates), 3)
        self.assertEqual(self.calls("sleep"), [["0"], ["0"]])
        self.assertEqual(self.calls("sns_until"), [["boot"]])

    def test_nix_update_failure_never_applies_system(self):
        result = self.run_script(
            "nix/nix_update", "--no-exclude-file", MOCK_NIX_FAILURES="9",
            NIX_RETRY_ATTEMPTS="2", NIX_RETRY_DELAY="0",
        )
        self.assertNotEqual(result.returncode, 0)
        updates = [call for call in self.calls("nix") if call[:2] == ["flake", "update"]]
        self.assertEqual(len(updates), 2)
        self.assertEqual(self.calls("sns_until"), [])

    def test_resolver_validates_hosts_and_returns_new_module_path(self):
        for host in HOSTS:
            result = self.run_entrypoint(self.resolver, "--repo", str(self.repo), "--host", host, "sns")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.strip(), str(self.sources["nix/sns"]))
        for host in ("lib", "unknown", "../desktop1", "desktop1/anything"):
            result = self.run_entrypoint(self.resolver, "--repo", str(self.repo), "--host", host)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unknown host", result.stderr)

    def test_resolver_finds_checkout_without_forwarding_tree(self):
        shutil.rmtree(self.entrypoints)
        result = subprocess.run(
            ["bash", str(self.resolver)], cwd=self.repo / "modules/home/nix-tools/scripts/nix",
            env={**self.env, "SPREADCONFIG_HOST": "thinkbook"},
            text=True, capture_output=True, timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.sources["nix/sns_until"]))

    def test_resolver_cli_host_overrides_environment_and_rejects_missing_script(self):
        result = self.run_entrypoint(
            self.resolver, "--repo", str(self.repo), "--host", "thinkbook",
            SPREADCONFIG_HOST="unknown",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        for script in ("missing", "../sns", "/tmp/sns"):
            result = self.run_entrypoint(self.resolver, "--repo", str(self.repo), "--host", "desktop1", script)
            self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
