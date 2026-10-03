---
name: segment-paper
description: Partition a normalized academic paper into contiguous, ordered, semantically coherent reading chunks while preserving exact source-block coverage, page anchors, formulas, figures, tables, captions, and dependencies. Use after ingestion, when rebuilding poor chunks, or when validating that each chunk focuses on one argument unit without omission or duplication.
---

# Segment Paper

Partition the paper without teaching, summarizing, translating, or answering it.

## Segment

1. Read [chunking-contract.md](references/chunking-contract.md).
2. Require `ingest=complete`. Read `paper.md`, `source-map.json`, and the extraction report in full.
3. Walk source blocks strictly in order and identify the smallest coherent semantic or argument unit that can be read independently with its immediate evidence.
4. Keep a claim with its direct justification, equation derivation, figure/table evidence, qualification, or contrast. Prefer one or more complete paragraphs; use a single paragraph when it already forms a complete unit.
5. Create one file per chunk under `01 Chunks/`, copying the canonical source content and preserving block IDs and relative assets.
6. Write ordered entries to `chunk-map.json` and a readable `01 Chunks/index.md`.

## Limit Segmenter Commentary

Record only a precise title, source section, structural role, page span, dependencies, assets, and source-block list. Do not add interpretation that would pre-answer the Reader's work. A role such as `motivation`, `method-definition`, `derivation`, `experimental-evidence`, `limitation`, `appendix`, or `reference-list` is metadata, not a summary.

## Validate

Flatten all chunk source-block lists. They must equal the source map IDs exactly and in order. Reject:

- omitted, duplicated, reordered, or unknown blocks;
- a heading orphaned from the material it introduces;
- a claim split from direct evidence or a displayed equation;
- a figure/table separated from its caption or immediate discussion;
- chunks combined only to reach a preferred size.

Initialize every chunk with status `pending`, mark `segment=complete`, and run the workspace validator before handing the first chunk to the Reader.

