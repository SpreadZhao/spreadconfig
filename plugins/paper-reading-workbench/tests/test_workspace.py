#!/usr/bin/env python3

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import threading
import unittest
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

PLUGIN_ROOT = Path(__file__).resolve().parents[1]
WORKFLOW_SCRIPTS = PLUGIN_ROOT / "skills/run-paper-reading-workflow/scripts"
INGEST_SCRIPT = PLUGIN_ROOT / "skills/ingest-paper/scripts/ingest_paper.py"
INIT_SCRIPT = WORKFLOW_SCRIPTS / "init_paper_workspace.py"
VALIDATE_SCRIPT = WORKFLOW_SCRIPTS / "validate_workspace.py"


def run(*arguments: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, *arguments],
        check=check,
        capture_output=True,
        text=True,
    )


def write_minimal_pdf(path: Path, text: str) -> None:
    escaped = text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")
    stream = f"BT /F1 16 Tf 72 720 Td ({escaped}) Tj ET".encode("latin-1")
    objects = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
        b"<< /Length "
        + str(len(stream)).encode("ascii")
        + b" >>\nstream\n"
        + stream
        + b"\nendstream",
    ]
    output = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for number, value in enumerate(objects, start=1):
        offsets.append(len(output))
        output.extend(f"{number} 0 obj\n".encode("ascii"))
        output.extend(value)
        output.extend(b"\nendobj\n")
    xref = len(output)
    output.extend(f"xref\n0 {len(objects) + 1}\n".encode("ascii"))
    output.extend(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        output.extend(f"{offset:010d} 00000 n \n".encode("ascii"))
    output.extend(
        f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode(
            "ascii"
        )
    )
    path.write_bytes(bytes(output))


def write_image_only_pdf(path: Path) -> None:
    width = 120
    height = 80
    pixels = bytearray([255] * (width * height))
    for y in range(20, 60):
        for x in range(15, 105):
            if y in range(20, 27) or y in range(36, 43) or y in range(53, 60):
                pixels[y * width + x] = 0
    content = b"q 480 0 0 320 66 236 cm /Im0 Do Q"
    objects = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>",
        b"<< /Type /XObject /Subtype /Image /Width "
        + str(width).encode("ascii")
        + b" /Height "
        + str(height).encode("ascii")
        + b" /ColorSpace /DeviceGray /BitsPerComponent 8 /Length "
        + str(len(pixels)).encode("ascii")
        + b" >>\nstream\n"
        + bytes(pixels)
        + b"\nendstream",
        b"<< /Length "
        + str(len(content)).encode("ascii")
        + b" >>\nstream\n"
        + content
        + b"\nendstream",
    ]
    output = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for number, value in enumerate(objects, start=1):
        offsets.append(len(output))
        output.extend(f"{number} 0 obj\n".encode("ascii"))
        output.extend(value)
        output.extend(b"\nendobj\n")
    xref = len(output)
    output.extend(f"xref\n0 {len(objects) + 1}\n".encode("ascii"))
    output.extend(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        output.extend(f"{offset:010d} 00000 n \n".encode("ascii"))
    output.extend(
        f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode(
            "ascii"
        )
    )
    path.write_bytes(bytes(output))


class WorkspaceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="paper-workbench-test-")
        self.root = Path(self.temporary.name)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def initialize(self, title: str, source: Path, output: Path | None = None) -> Path:
        workspace = output or self.root / "workspace"
        run(
            str(INIT_SCRIPT),
            "--title",
            title,
            "--source",
            str(source),
            "--output",
            str(workspace),
        )
        return workspace

    def test_default_output_path_and_explicit_resume(self) -> None:
        source = self.root / "default.md"
        source.write_text("# Default\n\nCurrent directory output.\n", encoding="utf-8")
        arguments = [
            sys.executable,
            str(INIT_SCRIPT),
            "--title",
            "Default Path Paper",
            "--source",
            str(source),
        ]
        subprocess.run(
            arguments, cwd=self.root, check=True, capture_output=True, text=True
        )
        workspace = self.root / "Default Path Paper"
        self.assertTrue((workspace / ".paper-reading/workflow.json").is_file())
        subprocess.run(
            [*arguments, "--resume"],
            cwd=self.root,
            check=True,
            capture_output=True,
            text=True,
        )

    def test_unicode_title_resume_collision_and_portable_move(self) -> None:
        source = self.root / "source.md"
        source.write_text(
            "# Abstract\n\nA complete idea.\n\nA second idea.\n", encoding="utf-8"
        )
        workspace = self.initialize("测试 / Paper", source)
        self.assertTrue((workspace / "00 Source/original.md").is_file())
        self.assertTrue((workspace / "Start Here.md").is_file())

        run(
            str(INIT_SCRIPT),
            "--title",
            "测试 / Paper",
            "--source",
            str(source),
            "--output",
            str(workspace),
        )
        run(str(INGEST_SCRIPT), "--workspace", str(workspace))
        run(str(VALIDATE_SCRIPT), str(workspace))

        moved = self.root / "SecondBrain/Papers/测试 Paper"
        moved.parent.mkdir(parents=True)
        shutil.move(str(workspace), moved)
        run(str(VALIDATE_SCRIPT), str(moved))
        run(
            str(INIT_SCRIPT),
            "--title",
            "测试 / Paper",
            "--output",
            str(moved),
            "--resume",
        )
        moved_workflow = json.loads(
            (moved / ".paper-reading/workflow.json").read_text(encoding="utf-8")
        )
        self.assertEqual(moved_workflow["workspace"], str(moved.resolve()))

        collision = self.root / "collision"
        collision.mkdir()
        (collision / "unrelated.txt").write_text("keep", encoding="utf-8")
        result = run(
            str(INIT_SCRIPT),
            "--title",
            "Different",
            "--output",
            str(collision),
            check=False,
        )
        self.assertEqual(result.returncode, 2)
        self.assertEqual(
            (collision / "unrelated.txt").read_text(encoding="utf-8"), "keep"
        )

    def test_html_localizes_images(self) -> None:
        image = self.root / "diagram.png"
        image.write_bytes(
            bytes.fromhex(
                "89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c489"
                "0000000d49444154789c6360f8cff000000401010018dd8db10000000049454e44ae426082"
            )
        )
        source = self.root / "paper.html"
        source.write_text(
            "<html><body><h1>Method</h1><p>One mechanism.</p>"
            '<img src="diagram.png" alt="Diagram"><figcaption>Figure one.</figcaption>'
            "<table><tr><th>Model</th><th>Score</th></tr>"
            "<tr><td>Baseline</td><td>0.5</td></tr></table>"
            "</body></html>",
            encoding="utf-8",
        )
        workspace = self.initialize("HTML Paper", source)
        run(str(INGEST_SCRIPT), "--workspace", str(workspace))
        source_map = json.loads(
            (workspace / ".paper-reading/source-map.json").read_text()
        )
        self.assertTrue(source_map["assets"])
        self.assertIn("table", {block["type"] for block in source_map["blocks"]})
        for asset in source_map["assets"]:
            self.assertTrue((workspace / asset["path"]).is_file())
        run(str(VALIDATE_SCRIPT), str(workspace))

    @unittest.skipUnless(
        all(
            shutil.which(name)
            for name in ("pdfinfo", "pdftotext", "pdftoppm", "pdfimages")
        ),
        "Poppler tools are unavailable",
    )
    def test_pdf_renders_pages_and_extracts_text(self) -> None:
        source = self.root / "paper.pdf"
        write_minimal_pdf(
            source,
            "Synthetic paper paragraph with enough text for extraction verification.",
        )
        workspace = self.initialize("Synthetic PDF", source)
        run(str(INGEST_SCRIPT), "--workspace", str(workspace), "--render-dpi", "72")
        source_map = json.loads(
            (workspace / ".paper-reading/source-map.json").read_text()
        )
        self.assertTrue(source_map["blocks"])
        self.assertTrue(list((workspace / "assets/page-images").glob("*.png")))
        self.assertTrue((workspace / "00 Source/extracted.txt").is_file())
        run(str(VALIDATE_SCRIPT), str(workspace))

    @unittest.skipUnless(
        all(
            shutil.which(name)
            for name in ("pdfinfo", "pdftotext", "pdftoppm", "pdfimages")
        ),
        "Poppler tools are unavailable",
    )
    def test_direct_pdf_url_is_preserved(self) -> None:
        source = self.root / "served.pdf"
        write_minimal_pdf(source, "Paper downloaded from a direct local test URL.")

        class QuietHandler(SimpleHTTPRequestHandler):
            def log_message(self, format: str, *args: object) -> None:
                return

        handler = partial(QuietHandler, directory=str(self.root))
        server = ThreadingHTTPServer(("127.0.0.1", 0), handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            url = f"http://127.0.0.1:{server.server_port}/served.pdf"
            workspace = self.root / "url-workspace"
            run(
                str(INIT_SCRIPT),
                "--title",
                "URL Paper",
                "--source",
                url,
                "--output",
                str(workspace),
            )
            run(str(INGEST_SCRIPT), "--workspace", str(workspace), "--render-dpi", "72")
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)

        workflow = json.loads((workspace / ".paper-reading/workflow.json").read_text())
        self.assertEqual(workflow["source"]["kind"], "url")
        self.assertEqual(workflow["source"]["stored"], "00 Source/original.pdf")
        self.assertTrue((workspace / "00 Source/original.pdf").is_file())
        run(str(VALIDATE_SCRIPT), str(workspace))

    @unittest.skipUnless(
        all(
            shutil.which(name)
            for name in ("pdfinfo", "pdftotext", "pdftoppm", "pdfimages", "tesseract")
        ),
        "PDF or OCR tools are unavailable",
    )
    def test_scanned_pdf_uses_ocr_fallback(self) -> None:
        source = self.root / "scan.pdf"
        write_image_only_pdf(source)
        workspace = self.initialize("Synthetic Scan", source)
        run(str(INGEST_SCRIPT), "--workspace", str(workspace), "--render-dpi", "72")
        metadata = json.loads((workspace / "00 Source/metadata.json").read_text())
        self.assertTrue(metadata["extraction"]["used_ocr"])
        self.assertTrue(list((workspace / "assets/page-images").glob("*.png")))
        self.assertIn(
            "OCR fallback was attempted",
            (workspace / "00 Source/extraction-report.md").read_text(encoding="utf-8"),
        )
        run(str(VALIDATE_SCRIPT), str(workspace))

    def test_final_coverage_and_duplicate_detection(self) -> None:
        source = self.root / "source.md"
        source.write_text("# Method\n\nClaim.\n\nEvidence.\n", encoding="utf-8")
        workspace = self.initialize("Coverage Paper", source)
        run(str(INGEST_SCRIPT), "--workspace", str(workspace))
        source_map = json.loads(
            (workspace / ".paper-reading/source-map.json").read_text()
        )
        source_ids = [block["id"] for block in source_map["blocks"]]
        workflow = json.loads((workspace / ".paper-reading/workflow.json").read_text())
        chunk_id = f"{workflow['paper_id']}-C0001"
        chunk_file = f"01 Chunks/{chunk_id} · Method.md"
        chunk_body = ["# Method", ""]
        for source_id in source_ids:
            chunk_body.extend([f"Source block {source_id}", f"^{source_id}", ""])
        (workspace / chunk_file).write_text("\n".join(chunk_body), encoding="utf-8")
        chunk_map = {
            "schema_version": 1,
            "paper_id": workflow["paper_id"],
            "chunks": [
                {
                    "id": chunk_id,
                    "title": "Method",
                    "section": "Method",
                    "role": "method-definition",
                    "pages": [],
                    "file": chunk_file,
                    "source_block_ids": source_ids,
                    "depends_on": [],
                    "assets": [],
                    "status": "complete",
                }
            ],
        }
        (workspace / ".paper-reading/chunk-map.json").write_text(
            json.dumps(chunk_map, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        workflow["phase"] = "complete"
        for phase in workflow["phases"]:
            if phase != "validation":
                workflow["phases"][phase] = "complete"
        (workspace / ".paper-reading/workflow.json").write_text(
            json.dumps(workflow, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        question_id = f"{workflow['paper_id']}-Q0001"
        question = {
            "id": question_id,
            "origin_chunk": chunk_id,
            "question": "Why does the evidence support the claim?",
            "kind": "evidence",
            "status": "resolved",
            "blocking": False,
        }
        coverage = {
            "question_id": question_id,
            "status": "placed",
            "mode": "footnote",
            "target": workflow["publication_file"],
            "anchor": "Method",
        }
        (workspace / ".paper-reading/questions.jsonl").write_text(
            json.dumps(question, ensure_ascii=False) + "\n", encoding="utf-8"
        )
        (workspace / ".paper-reading/writer-coverage.jsonl").write_text(
            json.dumps(coverage, ensure_ascii=False) + "\n", encoding="utf-8"
        )
        publication_path = workspace / workflow["publication_file"]
        publication_path.write_text(
            publication_path.read_text(encoding="utf-8")
            + f"\nThe evidence supports the claim.[^{question_id}]\n\n"
            + f"[^{question_id}]: The controlled comparison isolates the claimed effect.\n",
            encoding="utf-8",
        )
        run(str(VALIDATE_SCRIPT), str(workspace), "--final")

        (workspace / ".paper-reading/writer-coverage.jsonl").write_text(
            "", encoding="utf-8"
        )
        missing_coverage = run(
            str(VALIDATE_SCRIPT), str(workspace), "--final", check=False
        )
        self.assertEqual(missing_coverage.returncode, 1)
        self.assertIn("has not been placed", missing_coverage.stderr)
        (workspace / ".paper-reading/writer-coverage.jsonl").write_text(
            json.dumps(coverage, ensure_ascii=False) + "\n", encoding="utf-8"
        )

        clean_publication = publication_path.read_text(encoding="utf-8")
        publication_path.write_text(
            clean_publication + "\n**原文：**\n", encoding="utf-8"
        )
        forbidden_label = run(
            str(VALIDATE_SCRIPT), str(workspace), "--final", check=False
        )
        self.assertEqual(forbidden_label.returncode, 1)
        self.assertIn("forbidden 原文/译文 label", forbidden_label.stderr)
        publication_path.write_text(clean_publication, encoding="utf-8")

        chunk_map["chunks"][0]["source_block_ids"] = source_ids + source_ids[:1]
        (workspace / ".paper-reading/chunk-map.json").write_text(
            json.dumps(chunk_map, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        result = run(str(VALIDATE_SCRIPT), str(workspace), "--final", check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("not an exact ordered partition", result.stderr)


if __name__ == "__main__":
    unittest.main()
