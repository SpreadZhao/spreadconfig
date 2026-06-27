#!/usr/bin/env python3
"""Preview or explicitly apply a leetcode-coach note patch."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

from extract_frontmatter import extract_frontmatter
from load_config import ConfigError, ensure_under, get_field, load_config, parse_yaml_subset, state_dir


FENCE_RE = re.compile(r"```(?P<lang>[a-zA-Z0-9_-]*)\n(?P<body>.*?)\n```", re.DOTALL)


def _extract_fences(patch_text: str) -> dict[str, list[str]]:
    fences: dict[str, list[str]] = {}
    for match in FENCE_RE.finditer(patch_text):
        lang = match.group("lang") or "text"
        fences.setdefault(lang.lower(), []).append(match.group("body"))
    return fences


def _merge_unique_list(existing: list[Any], incoming: list[Any]) -> list[Any]:
    result = list(existing)
    seen = {json.dumps(item, ensure_ascii=False, sort_keys=True) for item in result}
    for item in incoming:
        key = json.dumps(item, ensure_ascii=False, sort_keys=True)
        if key not in seen:
            result.append(item)
            seen.add(key)
    return result


def _merge_frontmatter(existing: Any, incoming: Any) -> Any:
    if isinstance(existing, dict) and isinstance(incoming, dict):
        merged = dict(existing)
        for key, value in incoming.items():
            if key in merged:
                merged[key] = _merge_frontmatter(merged[key], value)
            else:
                merged[key] = value
        return merged
    if isinstance(existing, list) and isinstance(incoming, list):
        return _merge_unique_list(existing, incoming)
    if existing in (None, "", []):
        return incoming
    return existing


def _format_scalar(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if value is None:
        return "null"
    text = str(value)
    if text == "" or any(char in text for char in [":", "#", "{", "}", "[", "]"]):
        return json.dumps(text, ensure_ascii=False)
    return text


def _dump_yaml(data: Any, indent: int = 0) -> list[str]:
    prefix = " " * indent
    if isinstance(data, dict):
        lines: list[str] = []
        for key, value in data.items():
            if isinstance(value, (dict, list)):
                lines.append(f"{prefix}{key}:")
                lines.extend(_dump_yaml(value, indent + 2))
            else:
                lines.append(f"{prefix}{key}: {_format_scalar(value)}")
        return lines
    if isinstance(data, list):
        lines = []
        for item in data:
            if isinstance(item, dict):
                lines.append(f"{prefix}-")
                lines.extend(_dump_yaml(item, indent + 2))
            elif isinstance(item, list):
                lines.append(f"{prefix}-")
                lines.extend(_dump_yaml(item, indent + 2))
            else:
                lines.append(f"{prefix}- {_format_scalar(item)}")
        return lines
    return [f"{prefix}{_format_scalar(data)}"]


def _compose_note(frontmatter: dict[str, Any], body: str) -> str:
    if frontmatter:
        return "---\n" + "\n".join(_dump_yaml(frontmatter)) + "\n---\n" + body.lstrip("\n")
    return body


def _target_under_notes(config: dict[str, Any], note: Path) -> Path:
    notes_root_raw = get_field(config, "repos.notes.local_path")
    if not notes_root_raw:
        raise ConfigError("Missing required config field: repos.notes.local_path")
    notes_root = Path(str(notes_root_raw)).resolve()
    resolved = note.resolve()
    try:
        resolved.relative_to(notes_root)
    except ValueError as exc:
        raise ConfigError(f"Note path must be under configured notes repo: {notes_root}") from exc
    return resolved


def merge_note(note_path: Path, patch_path: Path) -> str:
    note_text = note_path.read_text(encoding="utf-8") if note_path.exists() else ""
    patch_text = patch_path.read_text(encoding="utf-8")
    raw_frontmatter, frontmatter, body = extract_frontmatter(note_text)
    _ = raw_frontmatter

    fences = _extract_fences(patch_text)
    incoming_frontmatter: dict[str, Any] = {}
    if fences.get("yaml"):
        incoming_frontmatter = parse_yaml_subset(fences["yaml"][0])
    body_addition = "\n\n".join(fences.get("markdown", []))

    merged_frontmatter = _merge_frontmatter(frontmatter, incoming_frontmatter)
    if body_addition:
        separator = "\n\n" if body.strip() else ""
        body = body.rstrip() + separator + body_addition.strip() + "\n"
    return _compose_note(merged_frontmatter, body)


def main() -> int:
    parser = argparse.ArgumentParser(description="Preview or explicitly apply a note patch")
    parser.add_argument("--note", required=True)
    parser.add_argument("--patch", required=True)
    parser.add_argument("--output", default="")
    parser.add_argument("--apply", action="store_true")
    parser.add_argument(
        "--confirm-explicit-user-request",
        action="store_true",
        help="Required with --apply to modify the configured notes repository",
    )
    args = parser.parse_args()

    try:
        config = load_config()
        note_path = _target_under_notes(config, Path(args.note))
        merged = merge_note(note_path, Path(args.patch))
        if args.apply:
            if not args.confirm_explicit_user_request:
                raise ConfigError(
                    "--apply requires --confirm-explicit-user-request because notes are never modified by default"
                )
            note_path.parent.mkdir(parents=True, exist_ok=True)
            note_path.write_text(merged, encoding="utf-8")
            print(str(note_path))
        elif args.output:
            output = ensure_under(Path(args.output), state_dir(config) / "sessions", "output")
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(merged, encoding="utf-8")
            print(str(output))
        else:
            print(merged)
    except (ConfigError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
