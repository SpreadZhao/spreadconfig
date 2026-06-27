#!/usr/bin/env python3
"""Summarize a run-result.json failure into review and memory seed data."""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date
from pathlib import Path
from typing import Any


def _load(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def summarize(result: dict[str, Any]) -> dict[str, Any]:
    failure_type = result.get("failure_type")
    stdout = result.get("stdout_summary") or ""
    stderr = result.get("stderr_summary") or ""
    problem = result.get("problem") or {}
    language = result.get("language") or ""
    failed_case = result.get("failed_case")

    if not failure_type:
        return {
            "failed": False,
            "message": "Run passed; no failure summary is needed.",
            "memory_candidate": None,
        }

    key_logs = "\n".join(part for part in [stdout, stderr] if part).strip()
    if not key_logs:
        key_logs = "No stdout/stderr summary captured."

    return {
        "failed": True,
        "failure_type": failure_type,
        "key_logs": key_logs[:2000],
        "failed_case": failed_case,
        "likely_code_location": result.get("code_file") or "",
        "root_cause_hypotheses": [],
        "minimal_modification_direction": "",
        "recommended_rerun": {
            "command": result.get("command") or "",
            "case": failed_case,
        },
        "memory_candidate": {
            "id": "",
            "problem": str(problem.get("num") or ""),
            "title": str(problem.get("title") or ""),
            "language": language,
            "date": date.today().isoformat(),
            "type": "",
            "failure_type": failure_type,
            "symptom": key_logs[:500],
            "root_cause": "",
            "fix": "",
            "evidence": {
                "failed_case": failed_case or "",
                "session": "",
            },
            "note_target": "",
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Summarize run failure evidence")
    parser.add_argument("run_result")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    try:
        summary = summarize(_load(Path(args.run_result)))
    except (OSError, json.JSONDecodeError) as exc:
        print(str(exc), file=sys.stderr)
        return 2

    print(json.dumps(summary, ensure_ascii=False, indent=2 if args.pretty else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
