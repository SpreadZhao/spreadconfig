---
name: write-obsidian-paper
description: Act as the persistent Writer for a Paper Reading Workbench workspace, first producing a complete source-language and natural Chinese bilingual edition, then integrating every Reader–Answerer question thread at its exact reading location using portable Markdown, Obsidian callouts, footnotes, wikilinks, figures, tables, formulas, and child notes. Use for the initial bilingual draft, incremental enrichment, final publication editing, or Writer coverage repair.
---

# Write Obsidian Paper

Produce the reader-facing paper, not a transcript dump. Preserve a continuous learning path.

## Establish the Publication Contract

Read [obsidian-publication-contract.md](references/obsidian-publication-contract.md). Load `$obsidian-markdown` when available for current Obsidian syntax. If unavailable, follow the bundled contract exactly; do not block the workflow or require CSS, a theme, or a community plugin.

## Write the Complete Bilingual Draft First

Before the Reader–Answerer loop:

1. Read the verified canonical paper and source map in order.
2. Reproduce every permitted source block, including headings, formulas, algorithms, figures, tables, captions, appendices, footnotes, acknowledgements, and references.
3. Place each source-language block as a Markdown blockquote and its faithful Chinese translation immediately below as normal prose.
4. Use natural bilingual headings such as `## Methods · 方法`. Never add literal `原文：` or `译文：` labels.
5. Preserve stable source anchors and relative asset paths.
6. Complete the entire draft before marking `bilingual_draft=complete`.

Translate before explaining. Preserve technical terms, symbols, citations, identifiers, and variable names. On first useful mention, use `中文术语（English term）`, then keep terminology consistent.

## Integrate Question Threads Incrementally

After a thread is resolved, place the insight exactly where a reader first needs it:

- use a footnote for a short clarification;
- use a collapsible callout for a medium, high-value explanation;
- use a dedicated paper-scoped child note for a long or branching thread, with a concise local summary and wikilink alias.

Include the question ID in the placement and update `writer-coverage.jsonl`. Summarize all reasoning needed by the final reader, including uncertainty and external provenance. Do not paste raw Reader–Answerer turns or gather all thought into a detached section.

If a later answer changes an early translation or interpretation, repair the early passage and keep the question placement. Merge duplicated insights without dropping IDs.

## Final Edit

After all chunks and deferred questions are complete:

- make terminology and bilingual headings consistent;
- verify claims against the paper and research notes;
- restore every figure, table, formula, caption, appendix, and reference at its natural position;
- make mainline prose readable while keeping deeper material one click away;
- verify all relative links, embeds, footnotes, anchors, and paper-scoped wikilinks;
- confirm every question has a `placed` coverage record.

Only then mark publication and validation complete.

