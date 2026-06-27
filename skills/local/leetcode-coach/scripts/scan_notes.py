#!/usr/bin/env python3
"""Scan configured SecondBrain LeetCode notes."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

from extract_frontmatter import extract_frontmatter
from load_config import ConfigError, get_field, load_config, require_fields


PROBLEM_RE = re.compile(r"^(?P<num>\d+)[\s._-]+(?P<title>.+?)\.md$", re.IGNORECASE)


def _as_list(value: Any) -> list[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def _todos(body: str) -> list[str]:
    found: list[str] = []
    for line in body.splitlines():
        stripped = line.strip()
        if "TODO" in stripped or stripped.startswith("- [ ]"):
            found.append(stripped)
    return found


def _languages_from_implementations(frontmatter: dict[str, Any]) -> list[str]:
    implementations = frontmatter.get("implementations")
    if isinstance(implementations, dict):
        return sorted(str(key) for key in implementations.keys())
    return []


def scan_notes(config: dict[str, Any], problem_num: str | None = None) -> list[dict[str, Any]]:
    missing = require_fields(config, ["repos.notes.local_path", "repos.notes.leetcode_notes"])
    if missing:
        raise ConfigError(
            "Missing required config field(s): "
            + ", ".join(missing)
            + ". Fill them in the runtime config."
        )

    root = Path(str(get_field(config, "repos.notes.local_path")))
    notes_rel = Path(str(get_field(config, "repos.notes.leetcode_notes")))
    notes_dir = root / notes_rel
    if not notes_dir.exists():
        raise ConfigError(f"Configured notes directory does not exist: {notes_dir}")

    records: list[dict[str, Any]] = []
    for path in sorted(notes_dir.glob("*.md")):
        match = PROBLEM_RE.match(path.name)
        inferred_num = match.group("num") if match else ""
        if problem_num and inferred_num != problem_num:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        _, frontmatter, body = extract_frontmatter(text)
        num = str(frontmatter.get("num") or inferred_num)
        if problem_num and num != problem_num:
            continue
        title = str(frontmatter.get("title") or (match.group("title") if match else path.stem))
        records.append(
            {
                "num": num,
                "title": title,
                "path": str(path),
                "relative_path": str(path.relative_to(root)),
                "tags": _as_list(frontmatter.get("tags")),
                "mtrace": _as_list(frontmatter.get("mtrace")),
                "implementations": _languages_from_implementations(frontmatter),
                "todos": _todos(body),
            }
        )
    return records


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan configured LeetCode notes")
    parser.add_argument("--problem-num")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    try:
        config = load_config()
        records = scan_notes(config, args.problem_num)
    except (ConfigError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 2

    print(json.dumps(records, ensure_ascii=False, indent=2 if args.pretty else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
