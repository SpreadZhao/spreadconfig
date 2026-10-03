#!/usr/bin/env python3
"""Standalone skill path tests; no Nix operations or business-data writes."""

from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
LOADER = ROOT / "skills/local/leetcode-coach/scripts/load_config.py"
RESOLVER = ROOT / "skills/local/spreadconfig-nix/scripts/resolve-nix-script"


class SkillPathTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="skill paths ")
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.cwd = self.base / "arbitrary project/nested"
        self.cwd.mkdir(parents=True)
        self.env = {
            key: value for key, value in os.environ.items()
            if key not in {
                "LEETCODE_COACH_CONFIG", "LEETCODE_COACH_STATE_DIR",
                "SPREADCONFIG_REPO", "SPREADCONFIG_HOST", "GIT_DIR", "GIT_WORK_TREE",
            }
        }

    def config(self, path, value="explicit"):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f"marker: {value}\n")
        return path

    def run_command(self, command, *, cwd=None, env=None):
        return subprocess.run(
            command, cwd=cwd or self.cwd, env=self.env | (env or {}),
            text=True, capture_output=True, check=False,
        )

    def load(self, *, env=None, args=()):
        return self.run_command([sys.executable, str(LOADER), *args], env=env)

    def read_result(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def repo(self, name):
        root = self.base / name
        (root / "hosts/test-host").mkdir(parents=True)
        (root / "hosts/test-host/host.nix").touch()
        (root / "flake.nix").touch()
        script = root / "modules/home/nix-tools/scripts/nix/sns_until"
        script.parent.mkdir(parents=True)
        script.touch()
        return root

    def resolve(self, *, args=(), env=None, resolver=RESOLVER, cwd=None):
        return self.run_command(["bash", str(resolver), "--host", "test-host", *args], env=env, cwd=cwd)

    def assert_repo(self, result, root):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(root / "modules/home/nix-tools/scripts/nix/sns_until"))

    def test_existing_local_config(self):
        self.config(self.cwd / ".leetcode-coach/config.yaml")
        self.assertEqual(self.read_result(self.load()), {"marker": "explicit"})

    def test_nested_project_config_requires_explicit_path(self):
        config = self.config(self.cwd / "SpreadStudy/Leetcode/.leetcode-coach/config.yaml", "nested")
        result = self.load()
        self.assertEqual(result.returncode, 2)
        self.assertIn("Missing config file: .leetcode-coach/config.yaml", result.stderr)
        self.assertEqual(self.read_result(self.load(env={"LEETCODE_COACH_CONFIG": str(config)})), {"marker": "nested"})

    def test_explicit_config_precedes_state_environment_and_local(self):
        self.config(self.cwd / ".leetcode-coach/config.yaml", "local")
        state_config = self.config(self.base / "state override/config.yaml", "state")
        config = self.config(self.base / "explicit config/config.yaml")
        self.assertEqual(self.read_result(self.load(env={
            "LEETCODE_COACH_CONFIG": str(config), "LEETCODE_COACH_STATE_DIR": str(state_config.parent),
        })), {"marker": "explicit"})

    def test_explicit_state_config_precedes_local(self):
        self.config(self.cwd / ".leetcode-coach/config.yaml", "local")
        config = self.config(self.base / "explicit state/config.yaml")
        self.assertEqual(self.read_result(self.load(env={"LEETCODE_COACH_STATE_DIR": str(config.parent)})), {"marker": "explicit"})

    def test_missing_explicit_configuration_does_not_fall_back(self):
        self.config(self.cwd / ".leetcode-coach/config.yaml", "local")
        for name in ("LEETCODE_COACH_CONFIG", "LEETCODE_COACH_STATE_DIR"):
            with self.subTest(name=name):
                result = self.load(env={name: str(self.base / "missing")})
                self.assertEqual(result.returncode, 2)
                self.assertIn("Missing config file", result.stderr)
                self.assertFalse((self.base / "missing").exists())

    def test_explicit_api_path_precedes_config_environment(self):
        config = self.config(self.base / "explicit config/config.yaml")
        program = "import runpy,sys; module=runpy.run_path(sys.argv[1]); print(module['load_config'](sys.argv[2])['marker'])"
        result = self.run_command(
            [sys.executable, "-c", program, str(LOADER), str(config)],
            env={"LEETCODE_COACH_CONFIG": str(self.base / "missing.yaml")},
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "explicit")

    def test_missing_required_field_reports_config_path(self):
        config = self.config(self.cwd / ".leetcode-coach/config.yaml")
        result = self.load(args=("--require", "repos.notes.local_path"))
        self.assertEqual(result.returncode, 2)
        self.assertIn("repos.notes.local_path", result.stderr)
        self.assertIn(str(config.relative_to(self.cwd)), result.stderr)

    def test_no_config_does_not_create_state_or_guess_paths(self):
        before = set(self.base.rglob("*"))
        result = self.load()
        self.assertEqual(result.returncode, 2)
        self.assertIn("Missing config file", result.stderr)
        self.assertEqual(set(self.base.rglob("*")), before)

    def test_existing_config_does_not_inject_defaults_or_create_data(self):
        config = self.config(self.cwd / ".leetcode-coach/config.yaml")
        code = self.base / "business code"
        notes = self.base / "business notes"
        config.write_text(f'repos:\n  code:\n    local_path: "{code}"\n  notes:\n    local_path: "{notes}"\n')
        before = set(self.base.rglob("*"))
        self.assertEqual(self.read_result(self.load()), {"repos": {"code": {"local_path": str(code)}, "notes": {"local_path": str(notes)}}})
        self.assertEqual(set(self.base.rglob("*")), before)

    def test_resolver_explicit_repo_precedes_environment(self):
        repo = self.repo("explicit repository")
        other = self.repo("environment repository")
        self.assert_repo(self.resolve(args=("--repo", str(repo)), env={"SPREADCONFIG_REPO": str(other)}), repo)

    def test_resolver_repository_environment_precedes_checkout(self):
        repo = self.repo("environment repository")
        other = self.repo("current repository")
        self.assert_repo(self.resolve(env={"SPREADCONFIG_REPO": str(repo)}, cwd=other), repo)

    def test_resolver_missing_explicit_repository_does_not_fall_back(self):
        result = self.resolve(args=("--repo", str(self.base / "missing")))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unknown host", result.stderr)

    def test_resolver_validates_host_and_script(self):
        repo = self.repo("explicit repository")
        for args, message in ((("--host", "../test-host"), "unknown host"), (("../sns_until",), "invalid script name")):
            with self.subTest(args=args):
                result = self.resolve(args=("--repo", str(repo), *args))
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(message, result.stderr)

    def test_resolver_explicit_host_precedes_environment(self):
        repo = self.repo("explicit repository")
        self.assert_repo(self.resolve(args=("--repo", str(repo)), env={"SPREADCONFIG_HOST": "unknown-host"}), repo)

    def test_resolver_host_environment(self):
        repo = self.repo("explicit repository")
        result = self.run_command(["bash", str(RESOLVER), "--repo", str(repo)], env={"SPREADCONFIG_HOST": "test-host"})
        self.assert_repo(result, repo)

    def test_resolver_current_checkout_precedes_skill_source(self):
        repo = self.repo("current repository")
        child = repo / "subdir/nested"
        child.mkdir(parents=True)
        self.assert_repo(self.resolve(cwd=child), repo)

    def test_resolver_source_ancestor_fallback_through_symlink(self):
        repo = self.repo("central source")
        resolver = repo / "skills/local/spreadconfig-nix/scripts/resolve-nix-script"
        resolver.parent.mkdir(parents=True)
        shutil.copyfile(RESOLVER, resolver)
        entry = self.base / "installed resolver"
        entry.symlink_to(resolver)
        self.assert_repo(self.resolve(resolver=entry), repo)

    def test_resolver_without_checkout_reports_error(self):
        resolver = self.base / "standalone resolver"
        shutil.copyfile(RESOLVER, resolver)
        result = self.resolve(resolver=resolver)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("could not find spreadconfig repo root", result.stderr)


if __name__ == "__main__":
    unittest.main()
