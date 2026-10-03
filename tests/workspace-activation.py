#!/usr/bin/env python3
"""Test workspace activation in temporary directories, with no real Nix writes."""

import copy
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ACTIVATE = ROOT / "lib/workspace/activate.py"
START = "# >>> spreadconfig workspace (managed) >>>"
END = "# <<< spreadconfig workspace (managed) <<<"


def tree(path):
    """Capture files and links without following a link out of the fixture."""
    result = {}
    for parent, dirs, files in os.walk(path, followlinks=False):
        for name in sorted(dirs + files):
            item = Path(parent) / name
            relative = str(item.relative_to(path))
            if item.is_symlink():
                result[relative] = ("link", os.readlink(item))
            elif item.is_dir():
                result[relative] = ("directory",)
            else:
                result[relative] = ("file", item.read_bytes())
    return result


class WorkspaceActivation(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="workspace-activation-")
        self.addCleanup(self.temporary.cleanup)
        self.temp = Path(self.temporary.name)
        self.workspace = self.new_workspace("workspace with spaces")
        self.source = self.temp / "editable source"
        self.store = self.temp / "mock store"
        self.bundle = self.store / "workspace-bundle"
        self.bundle.mkdir(parents=True)
        self.local = self.skill(self.source / "skills/local/alpha", "alpha")
        self.pinned = self.skill(self.store / "alpha", "alpha", "pinned content")
        self.remote = self.skill(self.store / "remote", "remote")
        self.beta = self.skill(self.store / "beta", "beta")
        self.home = self.temp / "home"
        self.home.mkdir()
        self.bin = self.temp / "bin"
        self.bin.mkdir()
        self.log = self.temp / "nix-store.jsonl"
        mock = self.bin / "nix-store"
        mock.write_text(f"#!{sys.executable}\n" + '''
import json
import os
from pathlib import Path
import sys
args = sys.argv[1:]
with open(os.environ["MOCK_NIX_LOG"], "a") as stream:
    stream.write(json.dumps(args) + "\\n")
assert len(args) == 5 and args[0] == "--add-root" and args[2:4] == ["--indirect", "--realise"], args
if os.environ.get("MOCK_NIX_FAIL"):
    sys.exit(19)
root = Path(args[1])
assert root.parent.is_dir()
assert Path(args[4]).is_dir()
if os.path.lexists(root):
    assert root.is_symlink(), root
    root.unlink()
root.symlink_to(args[4])
print(args[4])
''')
        mock.chmod(0o755)
        self.env = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("SPREADCONFIG_", "AGENT_WORKSPACE_", "MOCK_"))
        }
        self.env.update(HOME=str(self.home), PATH=f"{self.bin}:{os.environ['PATH']}",
                        MOCK_NIX_LOG=str(self.log), SPREADCONFIG_SOURCE_ROOT=str(self.source))
        self.manifest = {
            "schemaVersion": 2,
            "skills": [
                {"name": "alpha", "relativePath": "skills/local/alpha"},
                {"name": "remote", "source": str(self.remote)},
            ],
            "claude": True,
            "instructions": "Keep the user's business files in their existing repositories.",
            "storeRoot": str(self.bundle),
        }

    def new_workspace(self, name):
        workspace = self.temp / name
        workspace.mkdir(parents=True)
        (workspace / "flake.nix").write_text("{ outputs = _: {}; }\n")
        return workspace

    def skill(self, directory, name, body="skill content"):
        directory.mkdir(parents=True)
        (directory / "SKILL.md").write_text(f"---\nname: {name}\ndescription: Example\n---\n{body}\n")
        (directory / "scripts").mkdir()
        (directory / "scripts/helper.py").write_text("# skill helper\n")
        return directory

    def run_activation(self, manifest=None, cwd=None, remove_env=(), **env):
        path = self.temp / "manifest.json"
        path.write_text(json.dumps(self.manifest if manifest is None else manifest))
        environment = {**self.env, **env}
        for key in remove_env:
            environment.pop(key, None)
        return subprocess.run([sys.executable, str(ACTIVATE), str(path)],
                              cwd=cwd or self.workspace, env=environment,
                              capture_output=True, text=True, timeout=10)

    def success(self, **kwargs):
        result = self.run_activation(**kwargs)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def fail_without_changes(self, message, workspace=None, **kwargs):
        target = workspace or self.workspace
        before, calls = tree(target), self.calls()
        result = self.run_activation(**kwargs)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(message, result.stderr)
        self.assertEqual(tree(target), before)
        self.assertEqual(self.calls(), calls, "preflight must finish before calling nix-store")
        return result

    def test_mixed_sources_and_client_links(self):
        subdir = self.workspace / "nested/path"
        subdir.mkdir(parents=True)
        result = self.success(cwd=subdir, AGENT_WORKSPACE_ROOT=str(self.home))
        self.assertEqual(result.stdout, str(self.workspace) + "\n")
        self.assertEqual((self.workspace / ".agents/skills/alpha").resolve(), self.local)
        self.assertEqual((self.workspace / ".agents/skills/remote").resolve(), self.remote)
        self.assertEqual(os.readlink(self.workspace / ".claude/skills/alpha"), "../../.agents/skills/alpha")
        self.assertEqual(os.readlink(self.workspace / "CLAUDE.md"), "AGENTS.md")
        self.assertFalse((self.workspace / ".codex").exists())
        self.assertEqual({path.name for path in (self.workspace / ".agent-workspace").iterdir()},
                         {"state.json", "store"})
        instructions = (self.workspace / "AGENTS.md").read_text()
        self.assertIn(self.manifest["instructions"], instructions)
        self.assertEqual(instructions, "# Workspace Instructions\n\n"
                         "Skills are available under `.agents/skills`.\n\n"
                         + self.manifest["instructions"] + "\n")
        self.assertTrue((self.workspace / ".agents/skills/alpha/scripts/helper.py").is_file())
        (self.local / "SKILL.md").write_text("edited locally\n")
        self.assertEqual((self.workspace / ".agents/skills/alpha/SKILL.md").read_text(), "edited locally\n")
        self.assertIn("pinned content", (self.pinned / "SKILL.md").read_text())
        self.assertEqual(self.calls(), [["--add-root", str(self.workspace / ".agent-workspace/store"),
                                         "--indirect", "--realise", str(self.bundle)]])

    def test_fixed_sources_keep_exact_paths_independent_of_local_environment(self):
        alias = self.store / "pinned-alias"
        alias.symlink_to(self.pinned)
        self.manifest["skills"][0] = {"name": "alpha", "source": str(alias)}
        self.success(SPREADCONFIG_SOURCE_ROOT="/missing/ignored/source")
        self.assertEqual(os.readlink(self.workspace / ".agents/skills/alpha"), str(alias))
        self.success(remove_env=("SPREADCONFIG_SOURCE_ROOT",))
        self.assertEqual(os.readlink(self.workspace / ".agents/skills/alpha"), str(alias))

    def test_remote_only_does_not_need_a_local_checkout(self):
        self.manifest["skills"] = [self.manifest["skills"][1]]
        self.success(remove_env=("SPREADCONFIG_SOURCE_ROOT",))
        self.assertEqual((self.workspace / ".agents/skills/remote").resolve(), self.remote)

    def test_empty_selection_does_not_need_a_local_checkout(self):
        self.manifest["skills"] = []
        self.manifest["claude"] = False
        self.success(remove_env=("SPREADCONFIG_SOURCE_ROOT",))
        self.assertFalse((self.workspace / ".agents").exists())
        self.assertFalse((self.workspace / ".claude").exists())

    def test_local_skill_requires_explicit_source(self):
        self.fail_without_changes("require SPREADCONFIG_SOURCE_ROOT", remove_env=("SPREADCONFIG_SOURCE_ROOT",))
        self.fail_without_changes("must be absolute", SPREADCONFIG_SOURCE_ROOT="relative/path")

    def test_local_skill_needs_no_pinned_source_at_runtime(self):
        shutil.rmtree(self.pinned)
        self.success()
        self.assertEqual((self.workspace / ".agents/skills/alpha").resolve(), self.local)

    def test_source_records_must_have_exactly_one_source_kind(self):
        for skill in (
            {"name": "alpha"},
            {"name": "alpha", "relativePath": "skills/local/alpha", "source": str(self.pinned)},
        ):
            with self.subTest(skill=skill):
                manifest = {**self.manifest, "skills": [skill]}
                self.fail_without_changes("exactly one", manifest=manifest)

    def test_unknown_manifest_fields_are_rejected(self):
        self.fail_without_changes("unexpected or missing manifest fields",
                                  manifest={**self.manifest, "unexpected": {}})

    def test_unsupported_state_versions_are_rejected_before_mutation(self):
        self.success()
        state_path = self.workspace / ".agent-workspace/state.json"
        original = json.loads(state_path.read_text())
        self.manifest["skills"] = []
        for version in (1, 3, "2", True):
            with self.subTest(version=version):
                state_path.write_text(json.dumps({**original, "schemaVersion": version}))
                self.fail_without_changes("unsupported workspace state schemaVersion")

    def test_unowned_user_files_are_left_alone(self):
        (self.workspace / ".agent-workspace").mkdir()
        document = self.workspace / "NOTES.md"
        data = self.workspace / ".agent-workspace/user-data.json"
        document.write_text("user's workspace document\n")
        data.write_text("user's custom data\n")
        self.success()
        self.manifest["skills"] = []
        self.success(remove_env=("SPREADCONFIG_SOURCE_ROOT",))
        self.assertEqual(document.read_text(), "user's workspace document\n")
        self.assertEqual(data.read_text(), "user's custom data\n")
        state = json.loads((self.workspace / ".agent-workspace/state.json").read_text())
        self.assertEqual(set(state["files"]), {"AGENTS.md"})

    def test_state_cannot_claim_an_unrelated_file(self):
        self.success()
        state_path = self.workspace / ".agent-workspace/state.json"
        state = json.loads(state_path.read_text())
        state["files"]["business.md"] = hashlib.sha256(b"user").hexdigest()
        state_path.write_text(json.dumps(state))
        (self.workspace / "business.md").write_text("user")
        self.fail_without_changes("unsafe owned files")

    def test_explicit_root_is_canonical_and_can_be_outside_cwd(self):
        alias = self.temp / "alias"
        alias.symlink_to(self.workspace)
        result = self.success(cwd=self.home, SPREADCONFIG_WORKSPACE_ROOT=str(alias))
        self.assertEqual(result.stdout.strip(), str(self.workspace))
        self.assertFalse((self.home / ".agent-workspace").exists())

    def test_explicit_root_requires_its_own_flake(self):
        self.fail_without_changes("must contain flake.nix", workspace=self.home,
                                  SPREADCONFIG_WORKSPACE_ROOT=str(self.home))

    def test_store_root_guard_applies_after_canonicalization(self):
        # Resolve a temporary alias; the command must reject before touching store.
        alias = self.temp / "store-alias"
        alias.symlink_to("/nix/store")
        if Path("/nix/store").is_dir():
            self.fail_without_changes("must not be in the Nix store",
                                      SPREADCONFIG_WORKSPACE_ROOT=str(alias))
        else:
            self.skipTest("no Nix store on this test host")

    def test_nearest_flake_wins(self):
        nested = self.workspace / "child"
        nested.mkdir()
        (nested / "flake.nix").write_text("{}")
        self.assertEqual(self.success(cwd=nested).stdout.strip(), str(nested))
        self.assertFalse((self.workspace / ".agent-workspace").exists())

    def test_no_root_fallback_to_inherited_agent_environment(self):
        self.fail_without_changes("no flake.nix", workspace=self.home, cwd=self.home,
                                  AGENT_WORKSPACE_ROOT=str(self.workspace))

    def test_repeat_preserves_files_and_user_gitignore_lines(self):
        ignore = self.workspace / ".gitignore"
        prefix = "# user's patterns\r\n*.log\r\n"
        ignore.write_bytes(prefix.encode())
        ignore.chmod(0o640)
        self.success()
        self.assertEqual(ignore.stat().st_mode & 0o777, 0o640)
        managed = ignore.read_bytes()
        self.assertTrue(managed.startswith(prefix.encode()))
        with ignore.open("ab") as stream:
            stream.write(b"\n# later user pattern\ncache/\n")
        before = tree(self.workspace)
        mtimes = {path: (self.workspace / path).stat().st_mtime_ns
                  for path, value in before.items() if value[0] == "file"}
        self.success()
        self.assertEqual(tree(self.workspace), before)
        self.assertEqual({path: (self.workspace / path).stat().st_mtime_ns for path in mtimes}, mtimes)
        self.assertEqual(len(self.calls()), 2, "refresh GC registration even when content is unchanged")

    def test_deselect_and_disable_claude_preserves_unrelated_files(self):
        self.success()
        custom = self.workspace / ".agents/skills/custom"
        custom.mkdir()
        (custom / "SKILL.md").write_text("user-owned")
        unrelated = self.workspace / ".claude/skills/unrelated"
        unrelated.symlink_to(self.beta)
        (self.workspace / ".claude/settings.json").write_text("{}")
        (self.workspace / ".codex").mkdir()
        (self.workspace / ".codex/config.toml").write_text("user config")
        self.manifest["skills"] = [self.manifest["skills"][1]]
        self.manifest["claude"] = False
        self.success()
        for relative in (".agents/skills/alpha", ".claude/skills/alpha", ".claude/skills/remote", "CLAUDE.md"):
            self.assertFalse(os.path.lexists(self.workspace / relative))
        self.assertEqual((custom / "SKILL.md").read_text(), "user-owned")
        self.assertEqual(unrelated.resolve(), self.beta)
        self.assertTrue((self.workspace / ".claude/settings.json").is_file())
        self.assertEqual((self.workspace / ".codex/config.toml").read_text(), "user config")
        ignore = (self.workspace / ".gitignore").read_text()
        self.assertNotIn("/.agents/skills/alpha", ignore)
        self.assertNotIn("/.claude/", ignore)

    def test_move_refreshes_local_links_and_gc_registration(self):
        source = self.workspace / "source"
        shutil.copytree(self.source, source)
        self.success(SPREADCONFIG_SOURCE_ROOT=str(source))
        moved = self.temp / "moved workspace"
        self.workspace.rename(moved)
        self.workspace = moved
        self.success(SPREADCONFIG_SOURCE_ROOT=str(moved / "source"))
        self.assertEqual((moved / ".agents/skills/alpha").resolve(), moved / "source/skills/local/alpha")
        self.assertEqual({path.name for path in (moved / ".agent-workspace").iterdir()},
                         {"state.json", "store"})
        self.assertEqual(self.calls()[-1][1], str(moved / ".agent-workspace/store"))

    def test_new_conflict_aborts_before_pruning(self):
        self.success()
        (self.workspace / ".agents/skills/beta").symlink_to(self.beta)
        self.manifest["skills"] = [{"name": "beta", "source": str(self.beta)}]
        self.fail_without_changes("unowned path")
        self.assertTrue((self.workspace / ".agents/skills/alpha").is_symlink())

    def test_user_document_is_never_adopted(self):
        (self.workspace / "AGENTS.md").write_text("user instructions")
        self.fail_without_changes("unowned path")
        self.assertFalse((self.workspace / ".agent-workspace").exists())

    def test_changed_owned_link_is_not_deleted(self):
        self.success()
        link = self.workspace / ".agents/skills/alpha"
        link.unlink()
        link.symlink_to(self.beta)
        self.manifest["skills"] = []
        self.fail_without_changes("owned link was replaced or edited")

    def test_edited_generated_file_blocks_all_updates(self):
        self.success()
        (self.workspace / "AGENTS.md").write_text("hand edited")
        self.manifest["skills"] = []
        self.fail_without_changes("generated file was replaced or edited")

    def test_missing_source_does_not_fall_back_or_prune(self):
        self.success()
        shutil.rmtree(self.local)
        self.manifest["skills"] = [self.manifest["skills"][0]]
        self.fail_without_changes("No such file or directory")
        self.assertTrue(os.path.lexists(self.workspace / ".agents/skills/remote"))

    def test_skill_names_and_relative_paths_reject_traversal(self):
        for field, value, diagnostic in (
            ("name", "../../victim", "unsafe skill name"),
            ("relativePath", "../alpha", "unsafe skill relativePath"),
            ("relativePath", "/tmp/alpha", "unsafe skill relativePath"),
            ("relativePath", "skills//alpha", "unsafe skill relativePath"),
        ):
            with self.subTest(field=field, value=value):
                manifest = copy.deepcopy(self.manifest)
                manifest["skills"][0][field] = value
                self.fail_without_changes(diagnostic, manifest=manifest)

    def test_local_symlink_cannot_escape_source_root(self):
        escape = self.source / "escape"
        escape.symlink_to(self.pinned)
        self.manifest["skills"][0]["relativePath"] = "escape"
        self.fail_without_changes("escapes SPREADCONFIG_SOURCE_ROOT")

    def test_symlinked_output_parents_are_not_followed(self):
        outside = self.temp / "outside"
        outside.mkdir()
        (outside / "user-file").write_text("preserve")
        for index, relative in enumerate((".agents", ".agents/skills", ".claude", ".agent-workspace")):
            with self.subTest(relative=relative):
                workspace = self.new_workspace(f"parent-case-{index}")
                link = workspace / relative
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(outside)
                before = tree(outside)
                self.fail_without_changes("symlinked output directory", workspace=workspace, cwd=workspace)
                self.assertEqual(tree(outside), before)

    def test_symlinked_state_or_gitignore_is_not_followed(self):
        victim = self.temp / "victim"
        victim.write_text("do not change")
        for index, relative in enumerate((".agent-workspace/state.json", ".gitignore")):
            with self.subTest(relative=relative):
                workspace = self.new_workspace(f"file-case-{index}")
                link = workspace / relative
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(victim)
                self.fail_without_changes("regular file", workspace=workspace, cwd=workspace)
                self.assertEqual(victim.read_text(), "do not change")

    def test_corrupt_state_cannot_claim_arbitrary_paths(self):
        self.success()
        state_path = self.workspace / ".agent-workspace/state.json"
        original = json.loads(state_path.read_text())
        for key in ("../victim", "/tmp/victim", ".agents/skills/../victim", ".codex/skills/alpha"):
            with self.subTest(path=key):
                state = copy.deepcopy(original)
                state["links"][key] = str(self.pinned)
                state_path.write_text(json.dumps(state))
                self.fail_without_changes("unsafe owned links")

    def test_missing_owned_outputs_can_be_recreated(self):
        self.success()
        for relative in ("AGENTS.md", ".gitignore", ".agents/skills/alpha", ".agent-workspace/store"):
            (self.workspace / relative).unlink()
        self.success()
        self.assertEqual((self.workspace / ".agents/skills/alpha").resolve(), self.local)
        self.assertTrue((self.workspace / "AGENTS.md").is_file())

    def test_frontmatter_validation_and_duplicate_skill_names(self):
        file = self.local / "SKILL.md"
        for content, diagnostic in (
            ("# no header", "missing skill frontmatter"),
            ("---\nname: alpha\n", "unterminated skill frontmatter"),
            ("---\ndescription: x\n---\n", "one frontmatter name"),
            ("---\nname: other\n---\n", "skill name mismatch"),
        ):
            with self.subTest(content=content):
                file.write_text(content)
                self.fail_without_changes(diagnostic)
        file.write_text("---\nname: 'alpha' # comment\n---\n")
        self.manifest["skills"].append(self.manifest["skills"][0])
        self.fail_without_changes("duplicate skill name")

    def test_quoted_frontmatter_names_work(self):
        (self.local / "SKILL.md").write_text('---\nname: "alpha"\n---\n')
        self.success()

    def test_gc_registration_failure_precedes_link_updates(self):
        self.success()
        before = tree(self.workspace)
        self.manifest["skills"] = []
        result = self.run_activation(MOCK_NIX_FAIL="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(tree(self.workspace), before)

    def test_user_changes_to_managed_ignore_block_are_protected(self):
        self.success()
        ignore = self.workspace / ".gitignore"
        ignore.write_text(ignore.read_text().replace("/AGENTS.md\n", "user-change\n"))
        self.fail_without_changes("managed .gitignore block is not owned or was edited")

    def test_unowned_managed_ignore_markers_are_not_adopted(self):
        (self.workspace / ".gitignore").write_text(START + "\nuser data\n" + END + "\n")
        self.fail_without_changes("managed .gitignore block is not owned or was edited")


if __name__ == "__main__":
    unittest.main()
