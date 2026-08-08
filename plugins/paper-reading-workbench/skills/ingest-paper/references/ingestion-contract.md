# Ingestion Contract

## Inputs

- Local PDF: copy the exact file, extract native text, render every page, extract embedded images, and use OCR only when native text is sparse.
- Direct PDF URL: follow ordinary redirects, save the response, then use the PDF path.
- DOI, arXiv, OpenReview, publisher, or author URL: prefer an authoritative downloadable paper. Save the landing HTML when it is the available source.
- HTML: preserve the complete original response, localize reachable images, and verify math, tables, generated content, and captions.
- Markdown or text: preserve the input formatting and assign stable blocks without paraphrasing.

Do not silently substitute a summary, abstract page, or third-party transcription for the full paper.

## Required Outputs

- immutable original source;
- `paper.md` containing all recoverable text in source order;
- `source-map.json` with ordered stable blocks and assets;
- `metadata.json` with provenance and identifiers;
- `extraction-report.md` describing method, coverage, and uncertainty;
- figures, tables, and page images under `assets/`.

## Fidelity Rules

- Preserve original wording before translation or explanation.
- Preserve citations, numbering, symbols, variables, equations, figure/table labels, and bibliography entries.
- Keep claim and evidence locations traceable to a page or source block.
- Store page images even when text extraction succeeds; they are the verification surface for layout-sensitive material.
- Treat embedded-image extraction as an aid, not proof of figure identity or location. Use captions and page inspection to rename and place assets.
- Never smooth over missing symbols or uncertain OCR. Record a confidence value and a page-image pointer.

## Canonical Block Design

Prefer one source block per heading, coherent paragraph, displayed equation, table, figure/caption unit, list, algorithm, or bibliographic entry. Do not split inline citations or sentence fragments merely to reach a token size. Source blocks are fine-grained traceability units; semantic chunks are created later.

Artificial page comments may aid navigation but must not be counted as paper content. Every real source element must receive exactly one stable ID.
