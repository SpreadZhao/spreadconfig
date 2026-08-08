---
name: run-paper-reading-workflow
description: Orchestrate a complete, resumable academic-paper reading workflow from a PDF, URL, DOI/arXiv page, HTML, Markdown, or text input into one self-contained bilingual Obsidian workspace. Use when a user asks to deeply read, study, translate, annotate, question, research, or publish a paper rather than perform only one isolated ingestion, segmentation, answering, or writing phase.
---

# Run Paper Reading Workflow

Create exactly one folder per paper and treat that folder as both the durable process record and the final lightweight Obsidian vault.

## Start or Resume

1. Read [workspace-contract.md](references/workspace-contract.md) and [state-machine.md](references/state-machine.md).
2. Resolve the paper title, source, and output location. Use the user's output path when given; otherwise use the current directory and the sanitized title.
3. Run `scripts/init_paper_workspace.py --title <title> [--source <source>] [--output <folder>]`. Reuse a valid existing workspace. Never overwrite an unrelated non-empty folder.
4. Run `scripts/validate_workspace.py <folder>` after every phase boundary.
5. Inspect `.paper-reading/workflow.json` and continue from the first incomplete phase. Files, not chat memory or Agent IDs, are the source of truth.

## Execute the Pipeline

Run these skills in order:

1. Use `$ingest-paper` to preserve the original, build canonical Markdown and assets, and record extraction uncertainty.
2. Use `$segment-paper` to create an exact ordered partition of source blocks.
3. Start the persistent Writer and use `$write-obsidian-paper` to finish the complete bilingual draft before the reading loop.
4. Start one persistent Reader with `$read-paper-sequentially` and one persistent Answerer with `$research-paper-questions`.
5. For each chunk, let the Reader read only that chunk, route its questions to the same Answerer, return answers to the same Reader, and repeat until the chunk completion gate passes.
6. After each resolved question thread, ask the same Writer to integrate it at the precise reading location and update Writer coverage.
7. Revisit deferred questions after the final chunk. Classify irreducible questions instead of pretending they are answered.
8. Ask the Writer for global editing, then run `scripts/validate_workspace.py <folder> --final`.

## Preserve Role Continuity

When collaboration tools are available, create exactly three long-lived role Agents for Reader, Answerer, and Writer and reuse their handles for the whole run. Keep ingestion and segmentation one-shot. Give every role the workspace path and tell it to checkpoint before returning.

When persistent Agents are unavailable, alternate the three roles serially but reconstruct each turn from the role's checkpoint, the ledgers, and the complete relevant files. Never merge their responsibilities into an untracked monologue.

## Completion Rules

Do not finish merely because every chunk was opened. Finish only when:

- every source block belongs to exactly one ordered chunk;
- every chunk passes the Reader completion gate;
- no blocking question remains;
- deferred questions were revisited and remaining uncertainty was classified;
- every question ID has a Writer placement record;
- the bilingual publication contains formulas, figures, tables, captions, appendices, and references at their natural locations;
- all links and assets validate after treating the paper folder as movable.

Do not require the Reader to exhaust every conceivable question. Require a stable explanation of the paper and an honest classification of open research questions.

