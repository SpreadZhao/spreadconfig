# Workspace Contract

## Ownership

One paper owns one folder. Keep originals, intermediate state, role artifacts, research, assets, and publication inside it. Do not create `.obsidian` by default. Use relative Markdown paths for navigation and assets. Use paper-scoped IDs in Obsidian wikilinks so moving the folder into a larger vault does not create ambiguous note names.

## Stable IDs

- Paper: `P` plus eight uppercase hash characters, for example `P12AB34CD`.
- Source block: `<paper-id>-S000001`.
- Chunk: `<paper-id>-C0001`.
- Question: `<paper-id>-Q0001`.

Never renumber an existing ID. Append new IDs when correcting or extending work.

## Canonical Source

`00 Source/paper.md` is the canonical readable paper. Each source element has a source comment and Obsidian block ID. `.paper-reading/source-map.json` records ordered blocks with:

- `id`, `ordinal`, `type`, and optional `page`;
- extraction `confidence`;
- `text_sha256` for traceability;
- assets separately as `type`, relative `path`, and optional `page`.

Preserve the original file independently. Do not treat the canonical Markdown as proof that PDF reading order, equations, or figures are correct; consult `extraction-report.md` and page images.

## Chunk Map

`.paper-reading/chunk-map.json` contains ordered `chunks`. Each chunk has:

- `id`, `title`, `section`, `role`, `pages`;
- relative `file`;
- ordered `source_block_ids`;
- `depends_on`, `assets`, and `status`.

Flattening all `source_block_ids` must equal the source-map block list exactly. Use status `pending`, `reading`, or `complete`.

## Question Ledger

Store one JSON object per line in `.paper-reading/questions.jsonl`. Use these fields:

- `id`, `origin_chunk`, `question`, `kind`, `status`, `blocking`;
- optional `parent_id` and `related_ids`;
- `answer_note`, `evidence` (`paper`, `external`, `inference`, `uncertainty`);
- `later_section` when the answer depends on unread paper material;
- `created_at`, `updated_at`.

Use active statuses `open`, `researching`, `answered`, and `deferred`. Final statuses are `resolved`, `deferred-reviewed`, `open-research`, or `unanswerable`.

Create a readable question note under `02 Reading/Questions/` and research note under `02 Reading/Research/` when a thread needs more than ledger fields.

## Writer Coverage

Store one JSON object per line in `.paper-reading/writer-coverage.jsonl` for every question ID:

- `question_id`, `status`, `mode`, `target`, `anchor`, `updated_at`;
- `mode` is `footnote`, `callout`, or `child-note`;
- final `status` is `placed`.

The ledger proves coverage; it does not replace checking the actual prose.

## File Mutation

Write checkpoints after every meaningful transition. Keep JSON valid and JSONL append-safe. When updating a JSONL record, rewrite the ledger with exactly one record per ID rather than appending contradictory duplicates. Preserve user edits and never delete an artifact merely because a later summary supersedes it.

