#!/usr/bin/env python3
"""Exercise real Nix template initialization and workspace shell activation.

Only temporary workspaces and a temporary editable skill checkout are mutated.
The central flake inputs, Git index, home agent directories and deployments are
not changed. Nix may realize the small development-shell/check closures.
"""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
OPTIONS = None
REPORT = None
COMMANDS = []


def nix_string(value):
    return json.dumps(str(value)).replace("${", "\\${")


def snapshot(root):
    """Capture managed content, without following links to external sources."""
    result = {}
    for name in (".agents", ".claude", ".agent-workspace", "AGENTS.md", "CLAUDE.md", "WORKSPACE.md", ".gitignore"):
        path = root / name
        paths = [path]
        if path.is_dir() and not path.is_symlink():
            paths += list(path.rglob("*"))
        for item in paths:
            relative = item.relative_to(root).as_posix()
            if item.is_symlink():
                result[relative] = ("link", os.readlink(item))
            elif item.is_file():
                result[relative] = ("file", item.read_bytes())
            elif item.is_dir():
                result[relative] = ("dir",)
    return result


class WorkspaceFlake(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        global REPORT
        if not shutil.which("nix") or not shutil.which("nix-store"):
            raise unittest.SkipTest("Nix and nix-store are required")
        REPORT = Path(tempfile.mkdtemp(prefix="spreadconfig-workspace-flake-"))
        cls.scratch = REPORT / "fixtures"
        cls.scratch.mkdir()
        cls.environment = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("SPREADCONFIG_", "AGENT_WORKSPACE_"))
        }
        cls.system = cls.command(
            ["nix", "eval", "--impure", "--raw", "--expr", "builtins.currentSystem"],
            cls.scratch,
        ).stdout.strip()
        cls.source = cls.scratch / "Central Skills With Spaces"
        cls.source.mkdir()
        (cls.source / "flake.nix").write_text("{ outputs = _: {}; }\n")
        for name in ("android-dev", "segment-paper", "ingest-paper"):
            shutil.copytree(REPO / "skills/local" / name, cls.source / "skills/local" / name)
        cls.environment["SPREADCONFIG_SOURCE_ROOT"] = str(cls.source)

    @classmethod
    def tearDownClass(cls):
        if not OPTIONS.keep:
            shutil.rmtree(cls.scratch)

    @classmethod
    def command(cls, arguments, cwd, *, env=None, success=True):
        result = subprocess.run(
            arguments, cwd=cwd, env=env or cls.environment,
            text=True, capture_output=True, timeout=180,
        )
        COMMANDS.append({
            "command": arguments, "cwd": str(cwd), "returncode": result.returncode,
            "stdout": result.stdout, "stderr": result.stderr,
        })
        (REPORT / "commands.json").write_text(json.dumps(COMMANDS, indent=2) + "\n")
        if success and result.returncode:
            raise AssertionError(
                f"Command failed ({result.returncode}) in {cwd}: {arguments}\n"
                f"{result.stdout}\n{result.stderr}"
            )
        return result

    def declaration(self, root, *, skills=("android-dev",), claude=False, extra="{}"):
        skill_list = " ".join(nix_string(name) for name in skills)
        (root / "flake.nix").write_text(f'''{{
  description = "Temporary workspace integration fixture";
  inputs.spreadconfig.url = {nix_string("path:" + str(REPO))};
  outputs = {{ spreadconfig, ... }}: spreadconfig.lib.mkWorkspace {{
    systems = [ {nix_string(self.system)} ];
    skills = [ {skill_list} ];
    packages = _: [];
    claude = {str(claude).lower()};
    instructions = "Project notes are in ./Notes With Spaces. Keep this directory layout.";
    extraSkills = {extra};
  }};
}}
''')

    def initialize(self, name, **kwargs):
        root = self.scratch / name
        root.mkdir()
        self.command([
            "nix", "flake", "init", "--template", f"path:{REPO}#workspace",
        ], root)
        self.assertTrue((root / "flake.nix").is_file())
        self.assertFalse((root / "skills").exists())
        self.assertFalse((root / ".agent-workspace").exists())
        self.declaration(root, **kwargs)
        self.command(["nix", "flake", "lock"], root)
        return root

    def enter(self, root, *, cwd=None, source=True, success=True, script=None):
        environment = dict(self.environment)
        if not source:
            environment.pop("SPREADCONFIG_SOURCE_ROOT", None)
        script = script or 'printf "%s\\n" "$AGENT_WORKSPACE_ROOT"; test -z "${AGENT_WORKSPACE_CONTEXT+x}"'
        result = self.command([
            "nix", "develop", "--no-write-lock-file", "-c", "bash", "--noprofile", "--norc", "-c", script,
        ], cwd or root, env=environment, success=success)
        if success:
            self.assertEqual(result.stdout.splitlines(), [str(root.resolve())])
            self.assertFalse((root / ".agent-workspace/context.json").exists())
            self.assertFalse((root / "WORKSPACE.md").exists())
        return result

    def fixed_skill(self, root):
        source = root / "fixture-skill"
        source.mkdir()
        (source / "SKILL.md").write_text(
            "---\nname: android-custom\ndescription: Fixed source fixture\n---\nPinned skill content.\n"
        )
        return source

    def test_real_workspace_lifecycle(self):
        first = self.initialize("First Workspace With Spaces", skills=("android-dev", "segment-paper"), claude=True)
        second = self.initialize("Second Workspace", skills=("android-dev", "ingest-paper"))
        user_skill = first / ".agents/skills/user-owned"
        user_skill.mkdir(parents=True)
        (user_skill / "SKILL.md").write_text("User-owned skill content.\n")
        unrelated = first / ".agents/skills/user-link"
        unrelated.symlink_to(self.source)
        self.enter(first)
        self.enter(second)
        self.assertEqual(set(path.name for path in (first / ".agents/skills").iterdir()),
                         {"android-dev", "segment-paper", "user-owned", "user-link"})
        self.assertEqual(set(path.name for path in (second / ".agents/skills").iterdir()), {"android-dev", "ingest-paper"})
        self.assertEqual((first / ".agents/skills/android-dev").resolve(), (second / ".agents/skills/android-dev").resolve())
        self.assertEqual((first / "CLAUDE.md").resolve(), first / "AGENTS.md")
        self.assertEqual((first / ".claude/skills/android-dev").resolve(), (first / ".agents/skills/android-dev").resolve())
        self.assertFalse((first / ".codex/skills").exists())
        self.assertFalse((second / ".claude").exists())
        self.assertIn("Project notes are in ./Notes With Spaces.", (first / "AGENTS.md").read_text())
        self.assertEqual(set(path.name for path in (first / ".agent-workspace").iterdir()), {"state.json", "store"})

        shared = self.source / "skills/local/android-dev/SKILL.md"
        shared.write_text(shared.read_text() + "\nShared content changed during integration test.\n")
        for workspace in (first, second):
            self.assertIn("Shared content changed", (workspace / ".agents/skills/android-dev/SKILL.md").read_text())

        old = snapshot(first)
        nested = first / "nested/subdirectory"
        nested.mkdir(parents=True)
        self.enter(first, cwd=nested)
        self.assertEqual(snapshot(first), old)
        self.enter(first)
        self.assertEqual(snapshot(first), old)

        self.declaration(first, skills=("android-dev",), claude=False)
        self.enter(first)
        self.assertFalse((first / ".agents/skills/segment-paper").exists())
        self.assertFalse((first / ".claude/skills/android-dev").exists())
        self.assertFalse((first / "CLAUDE.md").exists())
        self.assertTrue((second / ".agents/skills/ingest-paper").is_symlink())
        self.declaration(first, skills=())
        self.enter(first, source=False)
        self.assertEqual(set(path.name for path in (first / ".agents/skills").iterdir()),
                         {"user-owned", "user-link"})
        self.assertEqual((user_skill / "SKILL.md").read_text(), "User-owned skill content.\n")
        self.assertEqual(unrelated.resolve(), self.source)

        moved = self.scratch / "Moved Workspace"
        first.rename(moved)
        self.enter(moved, source=False)
        self.assertIn("Project notes are in ./Notes With Spaces.", (moved / "AGENTS.md").read_text())
        bundle = (moved / ".agent-workspace/store").resolve()
        roots = self.command(["nix-store", "--query", "--roots", str(bundle)], moved).stdout
        self.assertIn(str(moved / ".agent-workspace/store"), roots)

    def test_fixed_sources_empty_selection_and_failure_preflight(self):
        empty = self.initialize("Empty Selection", skills=())
        self.enter(empty, source=False)
        self.assertTrue((empty / "AGENTS.md").is_file())

        fixed = self.initialize("Fixed Source Workspace", skills=(),
                                extra='{ "android-custom" = ./fixture-skill; }')
        fixed_source = self.fixed_skill(fixed)
        self.enter(fixed, source=False)
        pinned = (fixed / ".agents/skills/android-custom").resolve()
        self.assertTrue(str(pinned).startswith("/nix/store/"))
        self.assertNotEqual(pinned, fixed_source)
        (fixed_source / "SKILL.md").write_text((fixed_source / "SKILL.md").read_text() + "Not yet prepared.\n")
        self.assertNotIn("Not yet prepared.", (pinned / "SKILL.md").read_text())
        bundle = (fixed / ".agent-workspace/store").resolve()
        roots = self.command(["nix-store", "--query", "--roots", str(bundle)], fixed).stdout
        self.assertIn(str(fixed / ".agent-workspace/store"), roots)
        closure = self.command(["nix-store", "--query", "--requisites", str(bundle)], fixed).stdout.splitlines()
        self.assertIn(str(pinned), closure)

        mixed = self.initialize("Mixed Sources", extra='{ "android-custom" = ./fixture-skill; }')
        self.fixed_skill(mixed)
        self.enter(mixed)
        self.assertEqual((mixed / ".agents/skills/android-dev").resolve(), self.source / "skills/local/android-dev")
        self.assertTrue(str((mixed / ".agents/skills/android-custom").resolve()).startswith("/nix/store/"))
        before = snapshot(mixed)
        failed = self.enter(mixed, source=False, success=False, script='printf ran > COMMAND-RAN')
        self.assertNotEqual(failed.returncode, 0)
        self.assertIn("SPREADCONFIG_SOURCE_ROOT", failed.stderr)
        self.assertEqual(snapshot(mixed), before)
        self.assertFalse((mixed / "COMMAND-RAN").exists())

        editable = self.initialize("Failure Preflight", skills=("android-dev", "segment-paper"))
        self.enter(editable)
        old = snapshot(editable)
        marker = editable / "COMMAND-RAN"
        blocked_command = 'printf ran > COMMAND-RAN'
        missing = self.source / "skills/local/ingest-paper"
        hidden = missing.with_name("ingest-paper-hidden")
        missing.rename(hidden)
        try:
            self.declaration(editable, skills=("android-dev", "ingest-paper"))
            result = self.enter(editable, success=False, script=blocked_command)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(snapshot(editable), old)
            self.assertFalse(marker.exists())
        finally:
            hidden.rename(missing)

        for changes, diagnostic in [
            ({"skills": ("no-such-skill",)}, "Unknown workspace skills"),
            ({"extra": '{ "android-dev" = ./fixture-skill; }'}, "Conflicting skill names"),
        ]:
            with self.subTest(diagnostic=diagnostic):
                fixture = editable / "fixture-skill"
                fixture.mkdir(exist_ok=True)
                (fixture / "SKILL.md").write_text("---\nname: android-dev\ndescription: Fixture\n---\n")
                self.declaration(editable, **changes)
                result = self.enter(editable, success=False, script=blocked_command)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(diagnostic, result.stderr)
                self.assertEqual(snapshot(editable), old)
                self.assertFalse(marker.exists())

        conflict = self.initialize("User Instructions Conflict")
        (conflict / "AGENTS.md").write_text("User-owned instructions.\n")
        before = snapshot(conflict)
        result = self.enter(conflict, success=False, script=blocked_command)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unowned path", result.stderr)
        self.assertEqual(snapshot(conflict), before)
        self.assertFalse((conflict / "COMMAND-RAN").exists())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--keep", action="store_true", help="Keep temporary workspaces and their GC roots for inspection")
    OPTIONS = parser.parse_args()
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(WorkspaceFlake)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if REPORT:
        summary = {"tests": result.testsRun, "failures": len(result.failures), "errors": len(result.errors),
                   "keptFixtures": OPTIONS.keep, "commands": len(COMMANDS)}
        (REPORT / "report.json").write_text(json.dumps(summary, indent=2) + "\n")
        print(f"Integration report: {REPORT}")
    raise SystemExit(not result.wasSuccessful())
