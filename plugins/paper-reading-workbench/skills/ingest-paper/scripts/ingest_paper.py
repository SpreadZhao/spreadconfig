#!/usr/bin/env python3
"""Create a loss-aware canonical Markdown baseline and source map for a paper."""

from __future__ import annotations

import argparse
import hashlib
import mimetypes
import re
import shutil
import subprocess
import sys
import tempfile
from html.parser import HTMLParser
from pathlib import Path
from typing import Any, ClassVar
from urllib.parse import unquote, urljoin, urlparse
from urllib.request import Request, urlopen

WORKFLOW_SCRIPTS = (
    Path(__file__).resolve().parents[2] / "run-paper-reading-workflow" / "scripts"
)
sys.path.insert(0, str(WORKFLOW_SCRIPTS))

from workspace_lib import (
    SCHEMA_VERSION,
    assert_workspace,
    is_url,
    read_json,
    sha256_file,
    utc_now,
    workspace_root,
    write_json,
)

USER_AGENT = "PaperReadingWorkbench/0.1 (+local academic reading workflow)"


def run_command(command: list[str], *, binary: bool = False) -> str | bytes:
    completed = subprocess.run(command, check=True, capture_output=True)
    return (
        completed.stdout
        if binary
        else completed.stdout.decode("utf-8", errors="replace")
    )


def available(name: str) -> bool:
    return shutil.which(name) is not None


def download(url: str, target_directory: Path) -> tuple[Path, str | None]:
    request = Request(url, headers={"User-Agent": USER_AGENT})
    with urlopen(request, timeout=60) as response:
        content_type = response.headers.get_content_type()
        final_url = response.geturl()
        data = response.read()
    extension = Path(unquote(urlparse(final_url).path)).suffix.lower()
    if content_type == "application/pdf":
        extension = ".pdf"
    elif content_type in {"text/html", "application/xhtml+xml"}:
        extension = ".html"
    elif not extension:
        extension = mimetypes.guess_extension(content_type or "") or ".bin"
    destination = target_directory / f"original{extension}"
    if (
        destination.exists()
        and hashlib.sha256(destination.read_bytes()).digest()
        != hashlib.sha256(data).digest()
    ):
        raise ValueError(
            f"Refusing to replace a different downloaded source: {destination}"
        )
    if not destination.exists():
        destination.write_bytes(data)
    return destination, content_type


def materialize_source(
    root: Path, workflow: dict, override: str | None
) -> tuple[Path, dict]:
    record = dict(workflow.get("source") or {})
    requested = override or record.get("requested")
    stored = record.get("stored")
    if not requested and stored:
        return root / stored, record
    if not requested:
        raise ValueError("No source was provided to the workspace or ingestion command")

    if is_url(requested):
        source_path, content_type = download(requested, root / "00 Source")
        record = {
            "kind": "url",
            "requested": requested,
            "stored": source_path.relative_to(root).as_posix(),
            "sha256": sha256_file(source_path),
            "content_type": content_type,
        }
        return source_path, record

    requested_path = Path(requested).expanduser().resolve()
    if stored and (root / stored).is_file():
        source_path = root / stored
    else:
        if not requested_path.is_file():
            raise ValueError(f"Source file does not exist: {requested_path}")
        extension = requested_path.suffix.lower() or ".bin"
        source_path = root / "00 Source" / f"original{extension}"
        if source_path.exists() and sha256_file(source_path) != sha256_file(
            requested_path
        ):
            raise ValueError(
                f"Refusing to replace a different source file: {source_path}"
            )
        if not source_path.exists():
            shutil.copy2(requested_path, source_path)
    record = {
        "kind": "file",
        "requested": str(requested_path),
        "stored": source_path.relative_to(root).as_posix(),
        "sha256": sha256_file(source_path),
        "content_type": mimetypes.guess_type(source_path.name)[0],
    }
    return source_path, record


def paragraph_blocks(text: str, *, page: int | None = None) -> list[dict[str, Any]]:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    raw_blocks = re.split(r"\n[ \t]*\n+", text)
    blocks: list[dict[str, Any]] = []
    for raw in raw_blocks:
        cleaned = raw.strip()
        if not cleaned:
            continue
        block_type = "paragraph"
        if cleaned.startswith("#"):
            block_type = "heading"
        elif cleaned.startswith(("$$", "\\[", "\\begin{equation}")):
            block_type = "equation"
        elif "|" in cleaned and "\n" in cleaned:
            block_type = "table"
        elif cleaned.startswith("```"):
            block_type = "code"
        blocks.append(
            {"type": block_type, "text": cleaned, "page": page, "confidence": "machine"}
        )
    return blocks


def extract_pdf(
    source: Path, root: Path, paper_id: str, dpi: int
) -> tuple[list[dict], list[dict], dict, list[str]]:
    required = [
        name
        for name in ("pdfinfo", "pdftotext", "pdftoppm", "pdfimages")
        if not available(name)
    ]
    if required:
        raise ValueError(f"Missing required PDF tools: {', '.join(required)}")

    notes: list[str] = []
    metadata: dict[str, Any] = {}
    for line in str(run_command(["pdfinfo", str(source)])).splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            metadata[key.strip().lower().replace(" ", "_")] = value.strip()

    pages_dir = root / "assets/page-images"
    page_prefix = pages_dir / f"{paper_id}-page"
    run_command(["pdftoppm", "-png", "-r", str(dpi), str(source), str(page_prefix)])
    page_images = sorted(pages_dir.glob(f"{paper_id}-page-*.png"))

    figures_dir = root / "assets/figures"
    figure_prefix = figures_dir / f"{paper_id}-image"
    try:
        run_command(["pdfimages", "-all", str(source), str(figure_prefix)])
    except subprocess.CalledProcessError as error:
        notes.append(f"Embedded image extraction failed: exit {error.returncode}")
    figure_files = sorted(
        path for path in figures_dir.glob(f"{paper_id}-image-*.*") if path.is_file()
    )

    raw_text = run_command(["pdftotext", "-layout", str(source), "-"])
    assert isinstance(raw_text, str)
    visible_characters = len(re.sub(r"\s", "", raw_text))
    used_ocr = False
    if visible_characters < max(100, len(page_images) * 40):
        notes.append("Native PDF text was sparse; OCR fallback was attempted.")
        if available("ocrmypdf"):
            with tempfile.TemporaryDirectory(prefix="paper-reading-ocr-") as temporary:
                ocr_pdf = Path(temporary) / "ocr.pdf"
                try:
                    run_command(
                        [
                            "ocrmypdf",
                            "--skip-text",
                            "--rotate-pages",
                            "--deskew",
                            str(source),
                            str(ocr_pdf),
                        ]
                    )
                    raw_text = str(
                        run_command(["pdftotext", "-layout", str(ocr_pdf), "-"])
                    )
                    used_ocr = True
                except subprocess.CalledProcessError as error:
                    notes.append(f"OCRmyPDF failed: exit {error.returncode}")
        elif available("tesseract") and page_images:
            page_texts: list[str] = []
            for image in page_images:
                try:
                    page_texts.append(
                        str(run_command(["tesseract", str(image), "stdout"]))
                    )
                except subprocess.CalledProcessError as error:
                    notes.append(
                        f"Tesseract failed for {image.name}: exit {error.returncode}"
                    )
                    page_texts.append("")
            raw_text = "\f".join(page_texts)
            used_ocr = True
        else:
            notes.append(
                "No OCR tool was available; page images require visual recovery."
            )

    (root / "00 Source/extracted.txt").write_text(raw_text, encoding="utf-8")
    blocks: list[dict[str, Any]] = []
    for page_number, page_text in enumerate(raw_text.split("\f"), start=1):
        blocks.extend(paragraph_blocks(page_text, page=page_number))

    assets = [
        {"type": "page-image", "path": path.relative_to(root).as_posix(), "page": index}
        for index, path in enumerate(page_images, start=1)
    ]
    assets.extend(
        {
            "type": "embedded-image",
            "path": path.relative_to(root).as_posix(),
            "page": None,
        }
        for path in figure_files
    )
    metadata["used_ocr"] = used_ocr
    metadata["extracted_text_characters"] = len(raw_text)
    metadata["page_images"] = len(page_images)
    metadata["embedded_images"] = len(figure_files)
    notes.append(
        "Verify reading order, equations, tables, figures, and captions against page images."
    )
    return blocks, assets, metadata, notes


class PaperHTMLParser(HTMLParser):
    BLOCKS: ClassVar[set[str]] = {
        "p",
        "li",
        "blockquote",
        "figcaption",
        "pre",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
    }

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.events: list[dict[str, Any]] = []
        self.active_tag: str | None = None
        self.buffer: list[str] = []
        self.in_table = False
        self.table_rows: list[list[str]] = []
        self.table_row: list[str] | None = None
        self.table_cell: list[str] | None = None

    def flush(self) -> None:
        text = re.sub(r"\s+", " ", "".join(self.buffer)).strip()
        if text and self.active_tag:
            if self.active_tag.startswith("h") and self.active_tag[1:].isdigit():
                level = min(int(self.active_tag[1:]), 6)
                text = f"{'#' * level} {text}"
                block_type = "heading"
            elif self.active_tag == "blockquote":
                text = "\n".join(f"> {line}" for line in text.splitlines())
                block_type = "quote"
            elif self.active_tag == "li":
                text = f"- {text}"
                block_type = "list"
            elif self.active_tag == "pre":
                text = f"```\n{text}\n```"
                block_type = "code"
            else:
                block_type = "paragraph"
            self.events.append(
                {
                    "type": block_type,
                    "text": text,
                    "page": None,
                    "confidence": "machine",
                }
            )
        self.buffer = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        tag = tag.lower()
        if tag == "table":
            self.flush()
            self.in_table = True
            self.table_rows = []
        elif self.in_table and tag == "tr":
            self.table_row = []
        elif self.in_table and tag in {"td", "th"}:
            self.table_cell = []
        elif tag in self.BLOCKS:
            self.flush()
            self.active_tag = tag
        elif tag == "img":
            attributes = dict(attrs)
            source = attributes.get("src")
            if source:
                self.flush()
                self.events.append(
                    {
                        "type": "image",
                        "text": attributes.get("alt") or "figure",
                        "source": source,
                        "page": None,
                        "confidence": "machine",
                    }
                )

    def handle_endtag(self, tag: str) -> None:
        tag = tag.lower()
        if self.in_table and tag in {"td", "th"} and self.table_cell is not None:
            if self.table_row is not None:
                self.table_row.append(
                    re.sub(r"\s+", " ", "".join(self.table_cell)).strip()
                )
            self.table_cell = None
        elif self.in_table and tag == "tr" and self.table_row is not None:
            if self.table_row:
                self.table_rows.append(self.table_row)
            self.table_row = None
        elif self.in_table and tag == "table":
            self.in_table = False
            if self.table_rows:
                width = max(len(row) for row in self.table_rows)
                rows = [row + [""] * (width - len(row)) for row in self.table_rows]
                header = rows[0]
                markdown = [
                    "| " + " | ".join(header) + " |",
                    "| " + " | ".join("---" for _ in header) + " |",
                ]
                markdown.extend("| " + " | ".join(row) + " |" for row in rows[1:])
                self.events.append(
                    {
                        "type": "table",
                        "text": "\n".join(markdown),
                        "page": None,
                        "confidence": "machine",
                    }
                )
            self.table_rows = []
        elif tag == self.active_tag:
            self.flush()
            self.active_tag = None

    def handle_data(self, data: str) -> None:
        if self.table_cell is not None:
            self.table_cell.append(data)
        elif self.active_tag:
            self.buffer.append(data)

    def close(self) -> None:
        super().close()
        self.flush()


def localize_html_images(
    events: list[dict],
    source_directory: Path,
    root: Path,
    paper_id: str,
    base_url: str | None,
) -> tuple[list[dict], list[dict], list[str]]:
    assets: list[dict] = []
    notes: list[str] = []
    image_number = 0
    for event in events:
        if event.get("type") != "image":
            continue
        image_number += 1
        raw_source = event.pop("source")
        try:
            if base_url:
                resolved = urljoin(base_url, raw_source)
                request = Request(resolved, headers={"User-Agent": USER_AGENT})
                with urlopen(request, timeout=30) as response:
                    data = response.read()
                    content_type = response.headers.get_content_type()
                extension = Path(unquote(urlparse(resolved).path)).suffix.lower()
                extension = (
                    extension or mimetypes.guess_extension(content_type) or ".bin"
                )
            else:
                image_path = (source_directory / unquote(raw_source)).resolve()
                data = image_path.read_bytes()
                extension = image_path.suffix.lower() or ".bin"
            filename = f"{paper_id}-web-{image_number:04d}{extension}"
            destination = root / "assets/figures" / filename
            destination.write_bytes(data)
            relative = destination.relative_to(root).as_posix()
            event["text"] = f"![{event['text']}](../{relative})"
            assets.append({"type": "html-image", "path": relative, "page": None})
        except (OSError, ValueError) as error:
            event["text"] = f"![{event['text']}]({raw_source})"
            event["confidence"] = "uncertain"
            notes.append(f"Could not localize HTML image {raw_source!r}: {error}")
    return events, assets, notes


def extract_textual(
    source: Path, root: Path, paper_id: str, requested: str | None
) -> tuple[list[dict], list[dict], dict, list[str]]:
    text = source.read_text(encoding="utf-8", errors="replace")
    suffix = source.suffix.lower()
    if suffix in {".html", ".htm", ".xhtml"}:
        parser = PaperHTMLParser()
        parser.feed(text)
        parser.close()
        source_directory = source.parent
        if requested and not is_url(requested):
            requested_path = Path(requested).expanduser().resolve()
            if requested_path.is_file():
                source_directory = requested_path.parent
        blocks, assets, notes = localize_html_images(
            parser.events,
            source_directory,
            root,
            paper_id,
            requested if requested and is_url(requested) else None,
        )
        notes.append(
            "Verify HTML tables, math, and generated content against the saved original page."
        )
        return blocks, assets, {"format": "html", "characters": len(text)}, notes
    blocks = paragraph_blocks(text)
    return (
        blocks,
        [],
        {"format": suffix.lstrip(".") or "text", "characters": len(text)},
        [],
    )


def assign_ids(blocks: list[dict], paper_id: str) -> list[dict]:
    result: list[dict] = []
    for ordinal, block in enumerate(blocks, start=1):
        source_id = f"{paper_id}-S{ordinal:06d}"
        text = str(block["text"])
        result.append(
            {
                **block,
                "id": source_id,
                "ordinal": ordinal,
                "text_sha256": hashlib.sha256(text.encode("utf-8")).hexdigest(),
            }
        )
    return result


def canonical_markdown(title: str, blocks: list[dict]) -> str:
    output = [f"# {title}", ""]
    for block in blocks:
        page = f" | page: {block['page']}" if block.get("page") is not None else ""
        output.extend(
            [
                f"<!-- source-block: {block['id']}{page} -->",
                str(block["text"]),
                f"^{block['id']}",
                "",
            ]
        )
    return "\n".join(output).rstrip() + "\n"


def write_report(
    root: Path, source: Path, metadata: dict, notes: list[str], block_count: int
) -> None:
    lines = [
        "# Extraction Report",
        "",
        "- Status: mechanical baseline complete; agent verification still required",
        f"- Saved source: `{source.relative_to(root).as_posix()}`",
        f"- Canonical source blocks: {block_count}",
    ]
    for key in (
        "pages",
        "page_images",
        "embedded_images",
        "used_ocr",
        "extracted_text_characters",
    ):
        if key in metadata:
            lines.append(f"- {key.replace('_', ' ').title()}: {metadata[key]}")
    lines.extend(["", "## Uncertainty and required checks", ""])
    if notes:
        lines.extend(f"- {note}" for note in notes)
    else:
        lines.append(
            "- No mechanical extraction warning was raised; still compare against the original."
        )
    (root / "00 Source/extraction-report.md").write_text(
        "\n".join(lines) + "\n", encoding="utf-8"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Normalize a paper into canonical Markdown and assets."
    )
    parser.add_argument("--workspace", required=True, help="Paper workspace folder")
    parser.add_argument(
        "--source", help="Override a pending local file or http(s) source"
    )
    parser.add_argument(
        "--render-dpi", type=int, default=144, help="PDF page image resolution"
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = workspace_root(args.workspace)
    workflow = assert_workspace(root)
    source, source_record = materialize_source(root, workflow, args.source)
    suffix = source.suffix.lower()
    if suffix == ".pdf":
        blocks, assets, extraction, notes = extract_pdf(
            source, root, workflow["paper_id"], args.render_dpi
        )
    elif suffix in {".md", ".markdown", ".txt", ".html", ".htm", ".xhtml"}:
        blocks, assets, extraction, notes = extract_textual(
            source, root, workflow["paper_id"], source_record.get("requested")
        )
    else:
        raise ValueError(f"Unsupported paper source format: {suffix or source.name}")

    blocks = assign_ids(blocks, workflow["paper_id"])
    if not blocks:
        notes.append(
            "No textual source blocks were recovered; use page images or provide a better source."
        )
    (root / "00 Source/paper.md").write_text(
        canonical_markdown(workflow["title"], blocks), encoding="utf-8"
    )
    write_json(
        root / ".paper-reading/source-map.json",
        {
            "schema_version": SCHEMA_VERSION,
            "paper_id": workflow["paper_id"],
            "source": source_record,
            "blocks": [
                {key: value for key, value in block.items() if key != "text"}
                for block in blocks
            ],
            "assets": assets,
            "updated_at": utc_now(),
        },
    )
    metadata_path = root / "00 Source/metadata.json"
    metadata = read_json(metadata_path)
    metadata["source"] = source_record
    metadata["extraction"] = extraction
    metadata["updated_at"] = utc_now()
    write_json(metadata_path, metadata)
    write_report(root, source, extraction, notes, len(blocks))

    workflow["source"] = source_record
    workflow["phase"] = "ingesting"
    workflow["phases"]["ingest"] = "in_progress" if blocks else "blocked"
    workflow["updated_at"] = utc_now()
    write_json(root / ".paper-reading/workflow.json", workflow)
    print(
        f"BASELINE: {source} -> {root} ({len(blocks)} source blocks; verification required)"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, TypeError, ValueError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(2)
