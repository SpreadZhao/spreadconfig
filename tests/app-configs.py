#!/usr/bin/env python3
"""Check application behavior against the checked-in per-host fixtures.

Only evaluates Nix and runs `niri validate`; never builds or starts a session.
"""

import argparse
import copy
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import types
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "tests/fixtures/application-baseline"
MANIFEST = json.loads((FIXTURES / "manifest.json").read_text())
HOSTS = ("amd-desktop", "desktop1", "thinkbook", "zephyrus-m16")
COMMENT = re.compile(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/')


def without_comments(text):
    return COMMENT.sub(lambda m: m[0] if m[0].startswith('"') else "", text)


def jsonc(path):
    return json.loads(without_comments(path.read_text()))


def fixture_config(host, app, name):
    variants = MANIFEST["configs"][app][name]
    return FIXTURES / variants.get(host, variants["default"])


def check_assets(app):
    # Keep hashes of executable theme code and shared palettes, not copies of
    # theme documentation/screenshots that do not affect configuration behavior.
    for name, digest in MANIFEST["assets"][app].items():
        current = ROOT / "modules/home" / app / "files" / name
        assert hashlib.sha256(current.read_bytes()).hexdigest() == digest, (
            f"{app}: runtime asset changed: {name}"
        )


def kdl_nodes(text):
    # Preserve all child order and repeated top-level rule order. Only singleton
    # top-level section order changes when the host include is extracted.
    tokens = re.findall(r'"(?:\\.|[^"\\])*"|[{};\n]|[^\s{};]+', without_comments(text))
    pos = 0

    def parse():
        nonlocal pos
        result = []
        while pos < len(tokens):
            if tokens[pos] in (";", "\n"):
                pos += 1
                continue
            if tokens[pos] == "}":
                pos += 1
                return tuple(result)
            header = []
            while pos < len(tokens) and tokens[pos] not in ("{", "}", ";", "\n"):
                header.append(tokens[pos])
                pos += 1
            children = ()
            if pos < len(tokens) and tokens[pos] == "{":
                pos += 1
                children = parse()
            result.append((tuple(header), children))
        return tuple(result)

    return parse()


def sections(nodes):
    grouped = defaultdict(list)
    for header, children in nodes:
        grouped[header[0]].append((header, children))
    return dict(grouped)


def expand_kdl(path):
    return re.sub(
        r'^include "([^"]+)"\s*$',
        lambda m: expand_kdl(path.parent / m[1]),
        path.read_text(),
        flags=re.M,
    )


def check_niri():
    binary = shutil.which("niri")
    assert binary, "niri is required for native configuration validation"
    for host in HOSTS:
        with tempfile.TemporaryDirectory(prefix="spreadconfig-niri-") as tmp:
            dest = Path(tmp)
            for name in ("config.kdl", "common.kdl"):
                (dest / name).symlink_to(ROOT / "modules/home/niri/files" / name)
            (dest / "host.kdl").symlink_to(ROOT / "hosts" / host / "home/niri/host.kdl")
            new = sections(kdl_nodes(expand_kdl(dest / "config.kdl")))
            expected = sections(kdl_nodes(fixture_config(host, "niri", "config.kdl").read_text()))
            assert new == expected, f"{host}: Niri settings or ordered rules changed"
            result = subprocess.run(
                [binary, "validate", "--config", str(dest / "config.kdl")],
                capture_output=True, text=True,
            )
            assert result.returncode == 0, f"{host}: {result.stdout}{result.stderr}"


class Settings:
    def __init__(self, values, prefix=""):
        object.__setattr__(self, "values", values)
        object.__setattr__(self, "prefix", prefix)

    def __getattr__(self, key):
        return Settings(self.values, f"{self.prefix}{key}.")

    def __setattr__(self, key, value):
        self.values[f"{self.prefix}{key}"] = value


def run_qute(path, host_path=None):
    values, calls, snapshots = {}, [], []
    scope = {"c": Settings(values)}

    class Config:
        def source(self, name):
            assert name == "host.py" and host_path is not None
            exec(compile(host_path.read_text(), str(host_path), "exec"), scope)

        def __getattr__(self, name):
            return lambda *args, **kwargs: calls.append((name, args, kwargs))

    scope["config"] = Config()
    theme = types.ModuleType("themes")
    theme.setup = lambda c: snapshots.append(copy.deepcopy(values))
    previous = sys.modules.get("themes")
    sys.modules["themes"] = theme
    try:
        exec(compile(path.read_text(), str(path), "exec"), scope)
    finally:
        if previous is None:
            del sys.modules["themes"]
        else:
            sys.modules["themes"] = previous
    return values, calls, snapshots


def check_qutebrowser():
    shared = ROOT / "modules/home/qutebrowser/files"
    for host in HOSTS:
        host_path = ROOT / "hosts" / host / "home/qutebrowser/host.py"
        if not host_path.exists():
            host_path = shared / "host.py"
        assert run_qute(shared / "config.py", host_path) == run_qute(
            fixture_config(host, "qutebrowser", "config.py")
        ), f"{host}: qutebrowser assignments, bindings, or pre-theme values changed"
    check_assets("qutebrowser")


def first_wins(first, second):
    merged = copy.deepcopy(first)
    for key, value in second.items():
        if key not in merged:
            merged[key] = copy.deepcopy(value)
        elif isinstance(merged[key], dict) and isinstance(value, dict):
            merged[key] = first_wins(merged[key], value)
    return merged


def css_rules(text):
    text = re.sub(r"/\*[\s\S]*?\*/", "", text)
    rules = {}
    for selector, body in re.findall(r"([^{}]+)\{([^{}]*)\}", text):
        selector = selector.strip()
        rules.setdefault(selector, {}).update(
            item.strip().split(":", 1) for item in body.split(";") if item.strip()
        )
    return {k: {p.strip(): v.strip() for p, v in d.items()} for k, d in rules.items()}


def check_waybar():
    # Evaluate the actual module with transparent stand-ins for file derivations.
    # This checks profile/capability wiring without realizing any store outputs.
    expr = r'''
      let
        root = builtins.toPath ROOT_PATH;
        flake = builtins.getFlake ("path:" + ROOT_PATH);
        lib = flake.inputs.nixpkgs.lib;
        mkHost = import (root + "/hosts/lib") { inherit lib; };
        names = [ "amd-desktop" "desktop1" "thinkbook" "zephyrus-m16" ];
      in lib.genAttrs names (name:
        let
          host = mkHost {
            inherit name;
            declaration = import (root + "/hosts/${name}/host.nix");
          };
          result = import (root + "/modules/home/waybar") {
            inherit host lib;
            config.xdg.configHome = "/test/.config";
            pkgs = { waybar = "/unused"; writeText = name: text: text; };
            repoEntries = _: {};
            repoTree = _: entries: entries;
          };
        in result.xdg.configFile.waybar.source)
    '''.replace("ROOT_PATH", json.dumps(str(ROOT)))
    result = subprocess.run(
        ["nix", "eval", "--offline", "--impure", "--json", "--expr", expr],
        check=True, text=True, capture_output=True,
    )
    files = ROOT / "modules/home/waybar/files"
    generated = json.loads(result.stdout)
    for host, outputs in generated.items():
        entry = json.loads(outputs["config.jsonc"])
        includes = entry.pop("include")
        for name in includes:
            include = Path(name)
            assert include.parent == Path("/test/.config/waybar"), (
                f"{host}: Waybar include must use the absolute runtime config directory: {name}"
            )
            entry = first_wins(entry, jsonc(files / include.name))
        assert entry == jsonc(fixture_config(host, "waybar", "config.jsonc")), f"{host}: Waybar JSON changed"
        common = (files / "common.css").read_text().replace('@import "spreadzhao.css";', "")
        css = common + outputs["style.css"].replace('@import "common.css";', "")
        expected = fixture_config(host, "waybar", "style.css").read_text()
        expected = expected.replace('@import "spreadzhao.css";', "")
        assert css_rules(css) == css_rules(expected), f"{host}: Waybar CSS changed"
    check_assets("waybar")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    check_niri()
    check_qutebrowser()
    check_waybar()
    print("PASS: 4 hosts; Niri native validation and ordered settings, qutebrowser behavior, Waybar JSON/CSS equivalence")


if __name__ == "__main__":
    main()
