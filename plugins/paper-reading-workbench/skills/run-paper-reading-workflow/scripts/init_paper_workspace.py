#!/usr/bin/env python3
"""Create or safely resume one-paper Paper Reading Workbench workspace."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path
from urllib.parse import quote

from workspace_lib import (
    SCHEMA_VERSION,
    WORKFLOW_MARKER,
    assert_workspace,
    is_url,
    make_paper_id,
    safe_name,
    sha256_file,
    utc_now,
    workspace_root,
    write_json,
    write_text_if_missing,
)

DIRECTORIES = (
    ".paper-reading/logs",
    "00 Source",
    "01 Chunks",
    "02 Reading/Chunk Notes",
    "02 Reading/Questions",
    "02 Reading/Research",
    "03 Publication/Questions",
    "03 Publication/Concepts",
    "assets/figures",
    "assets/tables",
    "assets/page-images",
)


def markdown_href(relative_path: str) -> str:
    return quote(relative_path, safe="/.-_~")


def copy_source(root: Path, source: str) -> dict[str, str | None]:
    if is_url(source):
        return {"kind": "url", "requested": source, "stored": None, "sha256": None}

    source_path = Path(source).expanduser().resolve()
    if not source_path.is_file():
        raise ValueError(f"Source file does not exist: {source_path}")
    suffix = source_path.suffix.lower() or ".bin"
    destination = root / "00 Source" / f"original{suffix}"
    source_hash = sha256_file(source_path)
    if destination.exists():
        if sha256_file(destination) != source_hash:
            raise ValueError(
                f"Refusing to replace a different source file: {destination}"
            )
    elif source_path != destination:
        shutil.copy2(source_path, destination)
    return {
        "kind": "file",
        "requested": str(source_path),
        "stored": destination.relative_to(root).as_posix(),
        "sha256": source_hash,
    }


def create_workspace(root: Path, title: str, source: str | None) -> dict:
    for relative in DIRECTORIES:
        (root / relative).mkdir(parents=True, exist_ok=True)

    paper_id = make_paper_id(title, source)
    publication_name = f"{safe_name(title)} · 双语精读.md"
    created_at = utc_now()
    source_record = (
        copy_source(root, source)
        if source
        else {
            "kind": "pending",
            "requested": None,
            "stored": None,
            "sha256": None,
        }
    )
    workflow = {
        "schema_version": SCHEMA_VERSION,
        "paper_id": paper_id,
        "title": title,
        "workspace": str(root),
        "publication_file": f"03 Publication/{publication_name}",
        "source": source_record,
        "phase": "initialized",
        "current_chunk_id": None,
        "roles": {
            "reader": {"status": "pending", "checkpoint": "02 Reading/Reader State.md"},
            "answerer": {"status": "pending", "checkpoint": "02 Reading/Research"},
            "writer": {
                "status": "pending",
                "checkpoint": f"03 Publication/{publication_name}",
            },
        },
        "phases": {
            "ingest": "pending",
            "segment": "pending",
            "bilingual_draft": "pending",
            "sequential_reading": "pending",
            "publication": "pending",
            "validation": "pending",
        },
        "created_at": created_at,
        "updated_at": created_at,
    }
    write_json(root / WORKFLOW_MARKER, workflow)
    write_json(
        root / ".paper-reading/source-map.json",
        {
            "schema_version": SCHEMA_VERSION,
            "paper_id": paper_id,
            "blocks": [],
            "assets": [],
        },
    )
    write_json(
        root / ".paper-reading/chunk-map.json",
        {"schema_version": SCHEMA_VERSION, "paper_id": paper_id, "chunks": []},
    )
    (root / ".paper-reading/questions.jsonl").touch(exist_ok=True)
    (root / ".paper-reading/writer-coverage.jsonl").touch(exist_ok=True)

    write_json(
        root / "00 Source/metadata.json",
        {
            "schema_version": SCHEMA_VERSION,
            "paper_id": paper_id,
            "title": title,
            "identifiers": {},
            "source": source_record,
            "rights_status": "verify-before-full-reproduction",
            "created_at": created_at,
        },
    )
    write_text_if_missing(
        root / "00 Source/paper.md",
        f"# {title}\n\n> [!warning] Normalization pending\n> Run the ingestion phase before segmentation.\n",
    )
    write_text_if_missing(
        root / "00 Source/extraction-report.md",
        "# Extraction Report\n\n- Status: pending\n- Unreadable or uncertain regions: not assessed\n",
    )
    write_text_if_missing(
        root / "01 Chunks/index.md",
        f"# {title} · Chunk Index\n\nNo chunks have been created yet.\n",
    )
    write_text_if_missing(
        root / "02 Reading/Reader State.md",
        f"# Reader State\n\n- Paper: {title}\n- Paper ID: `{paper_id}`\n- Next chunk: pending segmentation\n\n## Cumulative Mental Model\n\n## Prior Connections\n\n## Deferred Questions\n",
    )
    write_text_if_missing(
        root / "02 Reading/Concept Glossary.md", "# Concept Glossary\n"
    )
    write_text_if_missing(root / "02 Reading/Open Questions.md", "# Open Questions\n")
    write_text_if_missing(root / "03 Publication/Sources.md", "# Sources\n")
    write_text_if_missing(
        root / "03 Publication" / publication_name,
        f"# {title} · 双语精读\n\n> [!info] Draft status\n> The complete bilingual edition has not been written yet.\n",
    )
    write_text_if_missing(
        root / "Start Here.md",
        "\n".join(
            [
                f"# {title}",
                "",
                f"- [双语精读]({markdown_href(f'03 Publication/{publication_name}')})",
                f"- [规范化原文]({markdown_href('00 Source/paper.md')})",
                f"- [分块索引]({markdown_href('01 Chunks/index.md')})",
                f"- [Reader 状态]({markdown_href('02 Reading/Reader State.md')})",
                f"- [开放问题]({markdown_href('02 Reading/Open Questions.md')})",
                f"- [来源与研究资料]({markdown_href('03 Publication/Sources.md')})",
                "",
                "> [!tip] Portable vault",
                "> This folder is self-contained. Move the whole folder to keep relative assets and links intact.",
                "",
            ]
        ),
    )
    return workflow


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create or safely resume a one-paper Obsidian workspace."
    )
    parser.add_argument("--title", required=True, help="Human-readable paper title")
    parser.add_argument("--source", help="Local file path or http(s) URL")
    parser.add_argument(
        "--output", help="Workspace folder; defaults to ./<sanitized title>"
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Require an existing Paper Reading Workbench workspace",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    title = args.title.strip()
    if not title:
        raise ValueError("--title must not be empty")
    root = workspace_root(args.output or (Path.cwd() / safe_name(title)))
    marker = root / WORKFLOW_MARKER
    exists_nonempty = root.exists() and any(root.iterdir())

    if marker.is_file():
        workflow = assert_workspace(root)
        if workflow.get("title") != title:
            raise ValueError(
                f"Workspace title mismatch: {workflow.get('title')!r} != {title!r}"
            )
        if args.source:
            requested_source = (
                args.source
                if is_url(args.source)
                else str(Path(args.source).expanduser().resolve())
            )
            if workflow.get("source", {}).get("requested") not in (
                None,
                requested_source,
            ):
                raise ValueError("Workspace already records a different source")
        if workflow.get("workspace") != str(root):
            workflow["workspace"] = str(root)
            workflow["updated_at"] = utc_now()
            write_json(marker, workflow)
        print(root)
        return 0
    if args.resume:
        raise ValueError(f"No resumable workspace exists at {root}")
    if exists_nonempty:
        raise ValueError(f"Refusing to use unrelated non-empty directory: {root}")

    root.mkdir(parents=True, exist_ok=True)
    create_workspace(root, title, args.source)
    print(root)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, TypeError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(2)
