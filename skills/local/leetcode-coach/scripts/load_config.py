#!/usr/bin/env python3
"""Load and validate leetcode-coach runtime config without external packages."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Any


STATE_DIR_NAME = ".leetcode-coach"
CONFIG_NAME = "config.yaml"
LEETCODE_ROOT = Path("SpreadStudy/Leetcode")
CONFIG_ENV = "LEETCODE_COACH_CONFIG"
STATE_DIR_ENV = "LEETCODE_COACH_STATE_DIR"


class ConfigError(RuntimeError):
    """Raised when leetcode-coach configuration is missing or invalid."""


def _strip_comment(line: str) -> str:
    in_single = False
    in_double = False
    escaped = False
    for index, char in enumerate(line):
        if escaped:
            escaped = False
            continue
        if char == "\\":
            escaped = True
            continue
        if char == "'" and not in_double:
            in_single = not in_single
            continue
        if char == '"' and not in_single:
            in_double = not in_double
            continue
        if char == "#" and not in_single and not in_double:
            return line[:index]
    return line


def _prepare_lines(text: str) -> list[tuple[int, str]]:
    prepared: list[tuple[int, str]] = []
    for raw in text.splitlines():
        if "\t" in raw[: len(raw) - len(raw.lstrip())]:
            raise ConfigError("Tabs are not supported in config indentation")
        line = _strip_comment(raw).rstrip()
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(" "))
        prepared.append((indent, line.strip()))
    return prepared


def _parse_scalar(value: str) -> Any:
    value = value.strip()
    if value == "":
        return ""
    if value in {"true", "True"}:
        return True
    if value in {"false", "False"}:
        return False
    if value in {"null", "Null", "NULL", "~"}:
        return None
    if (value.startswith('"') and value.endswith('"')) or (
        value.startswith("'") and value.endswith("'")
    ):
        return value[1:-1]
    if value.startswith("[") and value.endswith("]"):
        try:
            return json.loads(value)
        except json.JSONDecodeError:
            pass
    if re.fullmatch(r"-?\d+", value):
        try:
            return int(value)
        except ValueError:
            pass
    return value


def _collect_block_scalar(
    lines: list[tuple[int, str]], start: int, parent_indent: int, folded: bool
) -> tuple[str, int]:
    parts: list[str] = []
    index = start
    while index < len(lines):
        indent, content = lines[index]
        if indent <= parent_indent:
            break
        parts.append(content)
        index += 1
    if folded:
        return " ".join(parts), index
    return "\n".join(parts), index


def _split_mapping(content: str) -> tuple[str, str]:
    if ":" not in content:
        raise ConfigError(f"Expected mapping entry, got: {content}")
    key, value = content.split(":", 1)
    key = key.strip()
    if not key:
        raise ConfigError(f"Empty mapping key in: {content}")
    return key, value.strip()


def _parse_block(lines: list[tuple[int, str]], index: int, indent: int) -> tuple[Any, int]:
    if index >= len(lines):
        return {}, index

    is_list = lines[index][0] == indent and lines[index][1].startswith("- ")
    if is_list:
        result: list[Any] = []
        while index < len(lines):
            line_indent, content = lines[index]
            if line_indent < indent:
                break
            if line_indent != indent or not content.startswith("- "):
                break
            item = content[2:].strip()
            index += 1
            if item == "":
                if index < len(lines) and lines[index][0] > line_indent:
                    child, index = _parse_block(lines, index, lines[index][0])
                    result.append(child)
                else:
                    result.append(None)
            elif ":" in item and not item.startswith(("http://", "https://")):
                key, value = _split_mapping(item)
                record: dict[str, Any] = {}
                if value in {">", "|"}:
                    record[key], index = _collect_block_scalar(
                        lines, index, line_indent, folded=value == ">"
                    )
                elif value:
                    record[key] = _parse_scalar(value)
                elif index < len(lines) and lines[index][0] > line_indent:
                    child, index = _parse_block(lines, index, lines[index][0])
                    record[key] = child
                else:
                    record[key] = {}

                while index < len(lines) and lines[index][0] > line_indent:
                    child, index = _parse_block(lines, index, lines[index][0])
                    if isinstance(child, dict):
                        record.update(child)
                    else:
                        break
                result.append(record)
            else:
                result.append(_parse_scalar(item))
        return result, index

    result_dict: dict[str, Any] = {}
    while index < len(lines):
        line_indent, content = lines[index]
        if line_indent < indent:
            break
        if line_indent > indent:
            raise ConfigError(f"Unexpected indentation before: {content}")
        if content.startswith("- "):
            break
        key, value = _split_mapping(content)
        index += 1
        if value in {">", "|"}:
            result_dict[key], index = _collect_block_scalar(
                lines, index, line_indent, folded=value == ">"
            )
        elif value:
            result_dict[key] = _parse_scalar(value)
        elif index < len(lines) and lines[index][0] > line_indent:
            child, index = _parse_block(lines, index, lines[index][0])
            result_dict[key] = child
        else:
            result_dict[key] = {}
    return result_dict, index


def parse_yaml_subset(text: str) -> dict[str, Any]:
    """Parse the small YAML subset used by leetcode-coach templates."""

    lines = _prepare_lines(text)
    if not lines:
        return {}
    parsed, index = _parse_block(lines, 0, lines[0][0])
    if index != len(lines):
        raise ConfigError(f"Could not parse config near: {lines[index][1]}")
    if not isinstance(parsed, dict):
        raise ConfigError("Top-level config must be a mapping")
    return parsed


def default_state_dir() -> Path:
    configured = os.environ.get(STATE_DIR_ENV)
    if configured:
        return Path(configured)

    candidates = [
        Path(STATE_DIR_NAME),
        LEETCODE_ROOT / STATE_DIR_NAME,
    ]
    for candidate in candidates:
        if (candidate / CONFIG_NAME).exists():
            return candidate

    if LEETCODE_ROOT.exists():
        return LEETCODE_ROOT / STATE_DIR_NAME
    return Path(STATE_DIR_NAME)


def default_config_path() -> Path:
    configured = os.environ.get(CONFIG_ENV)
    if configured:
        return Path(configured)
    return default_state_dir() / CONFIG_NAME


def load_config(path: Path | str | None = None) -> dict[str, Any]:
    config_path = Path(path) if path is not None else default_config_path()
    if not config_path.exists():
        raise ConfigError(f"Missing config file: {config_path}")
    return parse_yaml_subset(config_path.read_text(encoding="utf-8"))


def get_field(data: dict[str, Any], dotted: str) -> Any:
    current: Any = data
    for part in dotted.split("."):
        if not isinstance(current, dict) or part not in current:
            return None
        current = current[part]
    return current


def is_missing(value: Any) -> bool:
    return value is None or value == "" or value == []


def require_fields(config: dict[str, Any], fields: list[str]) -> list[str]:
    return [field for field in fields if is_missing(get_field(config, field))]


def repository_values(config: dict[str, Any]) -> dict[str, str]:
    code = get_field(config, "repos.code") or {}
    notes = get_field(config, "repos.notes") or {}
    return {
        "code.local_path": str(code.get("local_path", "")),
        "code.leetcode_root": str(code.get("leetcode_root", "")),
        "notes.local_path": str(notes.get("local_path", "")),
        "notes.leetcode_notes": str(notes.get("leetcode_notes", "")),
        "notes.leetcode_template": str(notes.get("leetcode_template", "")),
    }


def render_template(value: Any, config: dict[str, Any], context: dict[str, Any] | None = None) -> Any:
    if not isinstance(value, str):
        return value
    replacements = repository_values(config)
    if context:
        replacements.update({key: "" if val is None else str(val) for key, val in context.items()})

    def replace(match: re.Match[str]) -> str:
        key = match.group(1)
        return replacements.get(key, match.group(0))

    return re.sub(r"\{([^{}]+)\}", replace, value)


def project_root() -> Path:
    return Path.cwd().resolve()


def state_dir(config: dict[str, Any] | None = None) -> Path:
    if config:
        configured = get_field(config, "skill.state_dir")
        if configured:
            return Path(str(configured))
    return default_state_dir()


def ensure_under(path: Path | str, base: Path | str, label: str) -> Path:
    root = project_root()
    resolved = (root / Path(path)).resolve() if not Path(path).is_absolute() else Path(path).resolve()
    resolved_base = (root / Path(base)).resolve() if not Path(base).is_absolute() else Path(base).resolve()
    try:
        resolved.relative_to(resolved_base)
    except ValueError as exc:
        raise ConfigError(f"{label} must be under {resolved_base}") from exc
    return resolved


def ensure_session_dir(path: Path | str, config: dict[str, Any] | None = None) -> Path:
    base = state_dir(config) / "sessions"
    return ensure_under(path, base, "session_dir")


def main() -> int:
    parser = argparse.ArgumentParser(description="Load leetcode-coach runtime config")
    parser.add_argument("--require", action="append", default=[])
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    config_path = default_config_path()
    try:
        config = load_config(config_path)
        missing = require_fields(config, args.require)
        if missing:
            fields = ", ".join(missing)
            raise ConfigError(
                f"Missing required config field(s): {fields}. Fill them in {config_path}."
            )
    except ConfigError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    indent = 2 if args.pretty else None
    print(json.dumps(config, ensure_ascii=False, indent=indent, sort_keys=bool(indent)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
