---
name: ingest-paper
description: Preserve and normalize an academic paper from a local PDF, URL, DOI/arXiv page, HTML, Markdown, or text into canonical Markdown, metadata, figures, tables, page images, stable source blocks, and an extraction report inside an existing Paper Reading Workbench workspace. Use for the ingestion phase or when paper extraction, OCR, source coverage, or asset recovery must be repaired.
---

# Ingest Paper

Create a complete, loss-aware input for later segmentation. Preserve evidence before interpreting it.

## Normalize Mechanically

1. Read [ingestion-contract.md](references/ingestion-contract.md).
2. Require a valid workspace created by `$run-paper-reading-workflow`.
3. Run `scripts/ingest_paper.py --workspace <folder> [--source <file-or-url>]` for the mechanical baseline.
4. Keep `00 Source/original.<ext>` unchanged. Never overwrite it with an OCR or cleaned derivative.
5. Do not bypass a paywall, authentication boundary, robots restriction, or access control. If the full source is unavailable, preserve metadata and the access failure, then ask for an authorized copy.

## Verify Against the Source

The script is not the finished ingestion. Inspect the original and, for PDFs, rendered page images using an available PDF/vision capability. Reconcile:

- reading order, headers, footers, columns, and page boundaries;
- headings, paragraphs, equations, algorithms, tables, figures, and captions;
- appendices, footnotes, acknowledgements, and references;
- missing glyphs, OCR substitutions, hyphenation, and image-only regions.

Correct `paper.md` without changing source-block order or IDs unnecessarily. When a correction changes block boundaries, update `source-map.json` and ensure every source element still appears exactly once. Keep uncertain text visibly marked and point to its page image instead of inventing content.

## Finish the Phase

Update metadata with identifiers, venue, authors, year, source URL, and rights status when known. List every unreadable, omitted, restricted, or uncertain region in `extraction-report.md`. Mark `ingest=complete` only after visual/source verification, then run the workspace validator.

Full reproduction is appropriate when the user supplied or authorized the document or the source permits it. Otherwise preserve the source reference and produce only the transformation allowed by access and rights.

