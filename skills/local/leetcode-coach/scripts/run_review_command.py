#!/usr/bin/env python3
"""Run a configured LeetCode review command and write run-result.json."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from load_config import (
    ConfigError,
    ensure_session_dir,
    get_field,
    load_config,
    render_template,
)


def _summary(text: str, limit: int = 2000) -> str:
    compact = "\n".join(line.rstrip() for line in text.strip().splitlines() if line.strip())
    if len(compact) <= limit:
        return compact
    return compact[: limit - 20] + "\n...<truncated>"


def _failed_case(stdout: str, stderr: str) -> str | None:
    text = stdout + "\n" + stderr
    patterns = [
        r"(?i)(failed case|failing case|input)\s*[:=]\s*(.+)",
        r"(?i)expected.+?got.+",
    ]
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            return match.group(0).strip()[:500]
    return None


def classify_failure(exit_code: int | None, stdout: str, stderr: str, timed_out: bool) -> str | None:
    if exit_code == 0 and not timed_out:
        return None
    text = (stdout + "\n" + stderr).lower()
    if timed_out:
        return "timeout"
    if any(token in text for token in ["compilation failed", "compile error", "compiler error"]):
        return "compile_error"
    if any(token in text for token in ["undefined reference", "no matching function", "cannot find symbol"]):
        return "compile_error"
    if any(token in text for token in ["segmentation fault", "nullpointerexception", "indexoutofbound", "panic"]):
        return "runtime_error"
    if any(token in text for token in ["wrong answer", "expected", "assert", "mismatch"]):
        return "wrong_answer"
    if any(token in text for token in ["memory limit", "outofmemory", "bad_alloc"]):
        return "memory_limit"
    if exit_code not in (0, None):
        return "test_command_failed"
    return "unknown_failure"


def _write_result(path: Path, result: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _base_result(args: argparse.Namespace) -> dict[str, Any]:
    return {
        "available": False,
        "source": "agent_run",
        "problem": {"num": args.problem_num or "", "title": args.problem_title or ""},
        "language": args.language,
        "code_file": args.code_file or "",
        "command": "",
        "cwd": "",
        "exit_code": None,
        "duration_ms": None,
        "stdout": "",
        "stderr": "",
        "stdout_summary": "",
        "stderr_summary": "",
        "failure_type": None,
        "failed_case": None,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Run configured LeetCode review command")
    parser.add_argument("--problem-num", required=True)
    parser.add_argument("--problem-title", default="")
    parser.add_argument("--language", required=True)
    parser.add_argument("--code-file", default="")
    parser.add_argument("--session-dir", required=True)
    parser.add_argument("--command", default="", help="One-time command from the current user request")
    parser.add_argument("--timeout", type=int, default=120)
    parser.add_argument("--output", default="")
    args = parser.parse_args()

    result = _base_result(args)
    output_path: Path | None = None

    try:
        config = load_config()
        session_dir = ensure_session_dir(args.session_dir, config)
        output_path = Path(args.output) if args.output else session_dir / "run-result.json"
        if args.output:
            output_path = ensure_session_dir(str(Path(args.output).parent), config) / Path(args.output).name

        language_config = get_field(config, f"languages.{args.language}")
        if not isinstance(language_config, dict):
            raise ConfigError(f"Missing language config: languages.{args.language}")

        command_template = args.command or str(language_config.get("run_command") or "")
        if not command_template:
            raise ConfigError(
                f"Cannot run review command: languages.{args.language}.run_command is empty.\n\n"
                "Fill this field in the runtime config, or provide a one-time command "
                "in the current request. The skill will not guess paths or generate a runner."
            )

        cwd_template = str(language_config.get("cwd") or "")
        if not cwd_template:
            raise ConfigError(f"Cannot run review command: languages.{args.language}.cwd is empty.")

        context = {
            "problem_num": args.problem_num,
            "problem_title": args.problem_title,
            "language": args.language,
            "code_file": args.code_file,
            "session_dir": str(session_dir),
        }
        command = str(render_template(command_template, config, context))
        cwd = Path(str(render_template(cwd_template, config, context)))
        if not cwd.exists():
            raise ConfigError(f"Configured command cwd does not exist: {cwd}")

        result["available"] = True
        result["command"] = command
        result["cwd"] = str(cwd)

        started = time.monotonic()
        timed_out = False
        try:
            completed = subprocess.run(
                command,
                cwd=str(cwd),
                shell=True,
                check=False,
                text=True,
                capture_output=True,
                timeout=args.timeout,
            )
            exit_code = completed.returncode
            stdout = completed.stdout
            stderr = completed.stderr
        except subprocess.TimeoutExpired as exc:
            timed_out = True
            exit_code = None
            stdout = exc.stdout if isinstance(exc.stdout, str) else ""
            stderr = exc.stderr if isinstance(exc.stderr, str) else ""
        duration_ms = int((time.monotonic() - started) * 1000)

        result.update(
            {
                "exit_code": exit_code,
                "duration_ms": duration_ms,
                "stdout": stdout,
                "stderr": stderr,
                "stdout_summary": _summary(stdout),
                "stderr_summary": _summary(stderr),
                "failure_type": classify_failure(exit_code, stdout, stderr, timed_out),
                "failed_case": _failed_case(stdout, stderr),
            }
        )
        _write_result(output_path, result)
    except (ConfigError, OSError) as exc:
        result["stderr_summary"] = str(exc)
        result["failure_type"] = "test_command_failed"
        if output_path is not None:
            _write_result(output_path, result)
        print(str(exc), file=sys.stderr)
        return 2

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["exit_code"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
