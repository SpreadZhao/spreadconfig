#!/usr/bin/env python3
"""Extract Markdown front matter as raw text and parsed JSON."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from load_config import ConfigError, parse_yaml_subset


def extract_frontmatter(text: str) -> tuple[str, dict[str, object], str]:
    if not text.startswith("---\n"):
        return "", {}, text
    end = text.find("\n---", 4)
    if end == -1:
        raise ConfigError("Opening front matter marker has no closing marker")
    raw = text[4:end].strip("\n")
    body_start = end + len("\n---")
    if text[body_start : body_start + 1] == "\n":
        body_start += 1
    parsed = parse_yaml_subset(raw) if raw.strip() else {}
    return raw, parsed, text[body_start:]


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract Markdown front matter")
    parser.add_argument("path")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    try:
        path = Path(args.path)
        text = path.read_text(encoding="utf-8")
        raw, parsed, body = extract_frontmatter(text)
    except (ConfigError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 2

    result = {
        "path": str(path),
        "has_frontmatter": bool(raw),
        "frontmatter_raw": raw,
        "frontmatter": parsed,
        "body": body,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2 if args.pretty else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
