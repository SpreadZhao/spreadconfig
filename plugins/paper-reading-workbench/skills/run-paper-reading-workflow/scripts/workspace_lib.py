#!/usr/bin/env python3
"""Shared helpers for Paper Reading Workbench workspace scripts."""

from __future__ import annotations

import hashlib
import json
import os
import re
import unicodedata
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SCHEMA_VERSION = 1
WORKFLOW_MARKER = Path(".paper-reading/workflow.json")


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def safe_name(value: str, *, fallback: str = "paper", limit: int = 120) -> str:
    value = unicodedata.normalize("NFKC", value).strip()
    value = re.sub(r"[\x00-\x1f\x7f]", "", value)
    value = re.sub(r"[\\/:*?\"<>|]", "-", value)
    value = re.sub(r"\s+", " ", value)
    value = re.sub(r"[-. ]{2,}", "-", value).strip(" .-")
    return (value or fallback)[:limit].rstrip(" .-")


def make_paper_id(title: str, source: str | None = None) -> str:
    seed = f"{unicodedata.normalize('NFKC', title).strip()}\n{source or ''}"
    digest = hashlib.sha256(seed.encode("utf-8")).hexdigest()[:8].upper()
    return f"P{digest}"


def read_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise TypeError(f"Expected a JSON object in {path}")
    return value


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp-{os.getpid()}")
    with temporary.open("w", encoding="utf-8") as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    os.replace(temporary, path)


def write_text_if_missing(path: Path, content: str) -> None:
    if path.exists():
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def is_url(value: str) -> bool:
    return re.match(r"^https?://", value, flags=re.IGNORECASE) is not None


def workspace_root(path: str | Path) -> Path:
    return Path(path).expanduser().resolve()


def assert_workspace(root: Path) -> dict[str, Any]:
    marker = root / WORKFLOW_MARKER
    if not marker.is_file():
        raise ValueError(f"Not a Paper Reading Workbench workspace: {root}")
    workflow = read_json(marker)
    if workflow.get("schema_version") != SCHEMA_VERSION:
        raise ValueError(
            f"Unsupported workspace schema {workflow.get('schema_version')!r}; "
            f"expected {SCHEMA_VERSION}"
        )
    return workflow
