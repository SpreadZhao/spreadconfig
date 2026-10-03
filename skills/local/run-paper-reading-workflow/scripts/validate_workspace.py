#!/usr/bin/env python3
"""Validate structure, coverage, state, and portable links in a paper workspace."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path
from urllib.parse import unquote

from workspace_lib import assert_workspace, read_json, workspace_root

REQUIRED_DIRECTORIES = (
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

REQUIRED_FILES = (
    "Start Here.md",
    ".paper-reading/workflow.json",
    ".paper-reading/source-map.json",
    ".paper-reading/chunk-map.json",
    ".paper-reading/questions.jsonl",
    ".paper-reading/writer-coverage.jsonl",
    "00 Source/paper.md",
    "00 Source/metadata.json",
    "00 Source/extraction-report.md",
    "01 Chunks/index.md",
    "02 Reading/Reader State.md",
    "02 Reading/Concept Glossary.md",
    "02 Reading/Open Questions.md",
    "03 Publication/Sources.md",
)

MARKDOWN_LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
WIKI_LINK_RE = re.compile(r"!?\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]")
FORBIDDEN_LABEL_RE = re.compile(
    r"^\s*(?:#{1,6}\s+|\*\*|__)?(?:原文|译文)\s*[:：]", re.IGNORECASE | re.MULTILINE
)


def load_jsonl(path: Path, errors: list[str]) -> list[dict]:
    records: list[dict] = []
    for line_number, raw in enumerate(
        path.read_text(encoding="utf-8").splitlines(), start=1
    ):
        if not raw.strip():
            continue
        try:
            value = json.loads(raw)
        except json.JSONDecodeError as error:
            errors.append(f"{path}: line {line_number}: invalid JSON: {error.msg}")
            continue
        if not isinstance(value, dict):
            errors.append(f"{path}: line {line_number}: expected a JSON object")
            continue
        records.append(value)
    return records


def resolve_link(root: Path, note: Path, raw_target: str) -> bool:
    target = unquote(raw_target.strip().strip("<>"))
    if not target or target.startswith(
        ("#", "http://", "https://", "mailto:", "data:")
    ):
        return True
    target = target.split("#", 1)[0].split("?", 1)[0]
    if target.startswith(("/", "file://")) or re.match(r"^[A-Za-z]:[\\/]", target):
        return False
    return (note.parent / target).resolve().exists()


def resolve_wikilink(root: Path, note: Path, raw_target: str) -> bool:
    target = unquote(raw_target.strip())
    if not target:
        return True
    if target.startswith(("/", "file://")) or re.match(r"^[A-Za-z]:[\\/]", target):
        return False
    relative = (note.parent / target).resolve()
    if relative.exists() or relative.with_suffix(".md").exists():
        return True
    root_relative = (root / target).resolve()
    if root_relative.exists() or root_relative.with_suffix(".md").exists():
        return True
    basename = Path(target).name
    candidates = list(root.rglob(basename))
    if not Path(basename).suffix:
        candidates.extend(root.rglob(f"{basename}.md"))
    return bool(candidates)


def validate_links(root: Path, errors: list[str]) -> None:
    for note in root.rglob("*.md"):
        text = note.read_text(encoding="utf-8")
        for raw_target in MARKDOWN_LINK_RE.findall(text):
            if not resolve_link(root, note, raw_target):
                errors.append(
                    f"Broken or non-portable Markdown link in {note}: {raw_target}"
                )
        for raw_target in WIKI_LINK_RE.findall(text):
            if not resolve_wikilink(root, note, raw_target):
                errors.append(
                    f"Broken or non-portable wikilink in {note}: {raw_target}"
                )


def validate_source_and_chunks(
    root: Path, final: bool, require_partition: bool, errors: list[str]
) -> None:
    source_map = read_json(root / ".paper-reading/source-map.json")
    chunk_map = read_json(root / ".paper-reading/chunk-map.json")
    blocks = source_map.get("blocks")
    chunks = chunk_map.get("chunks")
    if not isinstance(blocks, list):
        errors.append("source-map.json field `blocks` must be an array")
        blocks = []
    if not isinstance(chunks, list):
        errors.append("chunk-map.json field `chunks` must be an array")
        chunks = []

    source_ids = [block.get("id") for block in blocks if isinstance(block, dict)]
    if len(source_ids) != len(blocks) or not all(
        isinstance(value, str) and value for value in source_ids
    ):
        errors.append("Every source block must have a non-empty string ID")
    duplicates = [value for value, count in Counter(source_ids).items() if count > 1]
    if duplicates:
        errors.append(f"Duplicate source block IDs: {', '.join(duplicates)}")

    flattened: list[str] = []
    chunk_ids: list[str] = []
    for index, chunk in enumerate(chunks):
        if not isinstance(chunk, dict):
            errors.append(f"Chunk at index {index} is not an object")
            continue
        chunk_id = chunk.get("id")
        if not isinstance(chunk_id, str) or not chunk_id:
            errors.append(f"Chunk at index {index} has no valid ID")
            continue
        chunk_ids.append(chunk_id)
        chunk_file = chunk.get("file")
        if not isinstance(chunk_file, str) or not (root / chunk_file).is_file():
            errors.append(f"Chunk {chunk_id} references a missing file: {chunk_file!r}")
        block_ids = chunk.get("source_block_ids")
        if not isinstance(block_ids, list) or not all(
            isinstance(value, str) for value in block_ids
        ):
            errors.append(
                f"Chunk {chunk_id} must contain `source_block_ids` as strings"
            )
        else:
            flattened.extend(block_ids)
        if final and chunk.get("status") != "complete":
            errors.append(f"Chunk {chunk_id} is not complete")

    duplicate_chunks = [
        value for value, count in Counter(chunk_ids).items() if count > 1
    ]
    if duplicate_chunks:
        errors.append(f"Duplicate chunk IDs: {', '.join(duplicate_chunks)}")
    canonical_text = (root / "00 Source/paper.md").read_text(encoding="utf-8")
    for source_id in source_ids:
        anchor_count = len(
            re.findall(rf"^\^{re.escape(source_id)}$", canonical_text, re.MULTILINE)
        )
        if anchor_count != 1:
            errors.append(
                f"Canonical paper must contain exactly one anchor for {source_id}; found {anchor_count}"
            )
    if require_partition:
        for chunk in chunks:
            if not isinstance(chunk, dict) or not isinstance(chunk.get("file"), str):
                continue
            chunk_path = root / chunk["file"]
            if not chunk_path.is_file():
                continue
            chunk_text = chunk_path.read_text(encoding="utf-8")
            for source_id in chunk.get("source_block_ids", []):
                if not re.search(
                    rf"^\^{re.escape(source_id)}$", chunk_text, re.MULTILINE
                ):
                    errors.append(
                        f"Chunk {chunk.get('id')} is missing source anchor {source_id}"
                    )
    if source_ids and require_partition and flattened != source_ids:
        missing = [value for value in source_ids if value not in flattened]
        repeated = [value for value, count in Counter(flattened).items() if count > 1]
        unknown = [value for value in flattened if value not in set(source_ids)]
        detail = []
        if missing:
            detail.append(f"missing={missing}")
        if repeated:
            detail.append(f"repeated={repeated}")
        if unknown:
            detail.append(f"unknown={unknown}")
        if not detail:
            detail.append("source order differs")
        errors.append(
            "Chunk coverage is not an exact ordered partition: " + "; ".join(detail)
        )

    for asset in source_map.get("assets", []):
        if (
            isinstance(asset, dict)
            and isinstance(asset.get("path"), str)
            and not (root / asset["path"]).is_file()
        ):
            errors.append(f"Source map references a missing asset: {asset['path']}")


def validate_final_state(root: Path, workflow: dict, errors: list[str]) -> None:
    questions = load_jsonl(root / ".paper-reading/questions.jsonl", errors)
    coverage = load_jsonl(root / ".paper-reading/writer-coverage.jsonl", errors)
    question_ids = [item.get("id") for item in questions]
    if not all(isinstance(value, str) and value for value in question_ids):
        errors.append("Every question record must have a non-empty string ID")
    duplicate_questions = [
        value for value, count in Counter(question_ids).items() if count > 1
    ]
    if duplicate_questions:
        errors.append(f"Duplicate question IDs: {', '.join(duplicate_questions)}")
    allowed_final_statuses = {
        "resolved",
        "deferred-reviewed",
        "open-research",
        "unanswerable",
    }
    for question in questions:
        if (
            question.get("blocking") is True
            or question.get("status") not in allowed_final_statuses
        ):
            errors.append(
                f"Question {question.get('id', '<unknown>')} remains blocking or unclassified"
            )

    coverage_by_id = {
        item.get("question_id"): item
        for item in coverage
        if isinstance(item.get("question_id"), str)
    }
    coverage_ids = [
        item.get("question_id")
        for item in coverage
        if isinstance(item.get("question_id"), str)
    ]
    duplicate_coverage = [
        value for value, count in Counter(coverage_ids).items() if count > 1
    ]
    if duplicate_coverage:
        errors.append(f"Duplicate Writer coverage IDs: {', '.join(duplicate_coverage)}")
    for question_id in question_ids:
        record = coverage_by_id.get(question_id)
        if not record or record.get("status") != "placed":
            errors.append(f"Question {question_id} has not been placed by the Writer")
            continue
        target = record.get("target")
        if not isinstance(target, str) or not (root / target).is_file():
            errors.append(
                f"Question {question_id} has a missing Writer target: {target!r}"
            )
            continue
        if question_id not in (root / target).read_text(encoding="utf-8"):
            errors.append(
                f"Question {question_id} is absent from its claimed Writer target: {target}"
            )

    publication = workflow.get("publication_file")
    if not isinstance(publication, str) or not (root / publication).is_file():
        errors.append(f"Workflow publication file is missing: {publication!r}")
    else:
        text = (root / publication).read_text(encoding="utf-8")
        if FORBIDDEN_LABEL_RE.search(text):
            errors.append("Publication contains a forbidden 原文/译文 label")

    unfinished = [
        name
        for name, status in workflow.get("phases", {}).items()
        if name != "validation" and status != "complete"
    ]
    if unfinished:
        errors.append(f"Workflow phases are not complete: {', '.join(unfinished)}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate a Paper Reading Workbench workspace."
    )
    parser.add_argument("workspace", help="Path to the paper folder")
    parser.add_argument(
        "--final",
        action="store_true",
        help="Require all chunks, questions, Writer coverage, and phases to be complete",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = workspace_root(args.workspace)
    errors: list[str] = []
    try:
        workflow = assert_workspace(root)
    except (OSError, TypeError, ValueError, json.JSONDecodeError) as error:
        print(f"INVALID: {error}", file=sys.stderr)
        return 1

    for relative in REQUIRED_DIRECTORIES:
        if not (root / relative).is_dir():
            errors.append(f"Missing required directory: {relative}")
    for relative in REQUIRED_FILES:
        if not (root / relative).is_file():
            errors.append(f"Missing required file: {relative}")

    final = args.final or workflow.get("phase") == "complete"
    try:
        require_partition = (
            final or workflow.get("phases", {}).get("segment") == "complete"
        )
        validate_source_and_chunks(root, final, require_partition, errors)
        validate_links(root, errors)
        if final:
            validate_final_state(root, workflow, errors)
    except (OSError, TypeError, ValueError, json.JSONDecodeError) as error:
        errors.append(str(error))

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        print(f"INVALID: {len(errors)} error(s)", file=sys.stderr)
        return 1
    print(f"VALID: {root} ({'final' if final else 'structural'})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
