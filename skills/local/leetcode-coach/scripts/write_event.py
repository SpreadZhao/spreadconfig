#!/usr/bin/env python3
"""Append a JSONL event to a leetcode-coach session."""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

from load_config import ConfigError, ensure_session_dir, load_config


def _parse_field(raw: str) -> tuple[str, str]:
    if "=" not in raw:
        raise ConfigError(f"Expected key=value field, got: {raw}")
    key, value = raw.split("=", 1)
    if not key:
        raise ConfigError(f"Empty field key in: {raw}")
    return key, value


def main() -> int:
    parser = argparse.ArgumentParser(description="Write a leetcode-coach session event")
    parser.add_argument("--session-dir", required=True)
    parser.add_argument("--type", required=True, dest="event_type")
    parser.add_argument("--field", action="append", default=[], help="Add key=value string")
    parser.add_argument("--json-field", action="append", default=[], help="Add key=<json> value")
    parser.add_argument("--time", default=None)
    args = parser.parse_args()

    try:
        config = load_config()
        session_dir = ensure_session_dir(args.session_dir, config)
        session_dir.mkdir(parents=True, exist_ok=True)

        event: dict[str, object] = {
            "type": args.event_type,
            "time": args.time or datetime.now(timezone.utc).isoformat(),
        }
        for raw in args.field:
            key, value = _parse_field(raw)
            event[key] = value
        for raw in args.json_field:
            key, value = _parse_field(raw)
            event[key] = json.loads(value)

        events_path = session_dir / "events.jsonl"
        with events_path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(event, ensure_ascii=False, sort_keys=True))
            handle.write("\n")
    except (ConfigError, json.JSONDecodeError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 2

    print(str(events_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
