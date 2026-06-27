#!/usr/bin/env python3
"""Scan configured SpreadStudy LeetCode code files."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from load_config import ConfigError, get_field, load_config, render_template, require_fields


def _list_value(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, list):
        return [str(item) for item in value]
    return [str(value)]


def _contains_problem(path: Path, problem_num: str) -> bool:
    if problem_num in path.name:
        return True
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False
    return problem_num in text[:20000]


def scan_code(config: dict[str, Any], language: str | None = None, problem_num: str | None = None) -> list[dict[str, Any]]:
    missing = require_fields(config, ["repos.code.local_path", "repos.code.leetcode_root"])
    if missing:
        raise ConfigError(
            "Missing required config field(s): "
            + ", ".join(missing)
            + ". Fill them in the runtime config."
        )

    languages = get_field(config, "languages")
    if not isinstance(languages, dict):
        raise ConfigError("Missing languages mapping in the runtime config")

    records: list[dict[str, Any]] = []
    for lang, lang_config in sorted(languages.items()):
        if language and lang != language:
            continue
        if not isinstance(lang_config, dict) or lang_config.get("enabled") is False:
            continue
        source_root_raw = lang_config.get("source_root")
        if not source_root_raw:
            continue
        source_root = Path(str(render_template(source_root_raw, config)))
        if not source_root.exists():
            records.append(
                {
                    "language": lang,
                    "source_root": str(source_root),
                    "available": False,
                    "reason": "source_root does not exist",
                    "files": [],
                }
            )
            continue

        files: list[Path] = []
        for relative in _list_value(lang_config.get("primary_files")):
            candidate = source_root / relative
            if candidate.exists():
                files.append(candidate)
        for pattern in _list_value(lang_config.get("primary_globs")):
            files.extend(path for path in source_root.glob(pattern) if path.is_file())

        unique = sorted({path.resolve() for path in files})
        if problem_num:
            unique = [path for path in unique if _contains_problem(path, problem_num)]

        records.append(
            {
                "language": lang,
                "source_root": str(source_root),
                "available": True,
                "files": [str(path) for path in unique],
            }
        )
    return records


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan configured LeetCode code files")
    parser.add_argument("--language")
    parser.add_argument("--problem-num")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    try:
        config = load_config()
        records = scan_code(config, args.language, args.problem_num)
    except (ConfigError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 2

    print(json.dumps(records, ensure_ascii=False, indent=2 if args.pretty else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
