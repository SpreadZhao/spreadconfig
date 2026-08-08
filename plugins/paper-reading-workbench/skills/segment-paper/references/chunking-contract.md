# Chunking Contract

## Boundary Heuristics

Start a new chunk when the paper changes its immediate question, claim, mechanism, experimental comparison, proof step, limitation, or bibliographic function. Section boundaries are strong hints but not mandatory boundaries. Split a long section into argument units; join adjacent paragraphs only when the latter directly completes the former.

Keep these together:

- definition and immediate explanation;
- claim and proof or direct empirical evidence;
- equation and variable definitions;
- figure/table, caption, and the paragraph that interprets it;
- setup and the result that is unintelligible without it;
- caveat and the exact claim it limits.

Do not include distant background merely to make a chunk self-contained. Express that relationship in `depends_on` so the Reader must use cumulative context.

## Chunk File

Use a filename such as `<paper-id>-C0001 · <short-title>.md`. Put machine-readable metadata in frontmatter:

```yaml
---
chunk_id: P12AB34CD-C0001
section: "2.1 Method"
role: method-definition
pages: [3, 4]
source_blocks: [P12AB34CD-S000021, P12AB34CD-S000022]
depends_on: [P12AB34CD-C0000]
assets: [assets/figures/P12AB34CD-figure-01.png]
status: pending
---
```

After frontmatter, copy the relevant canonical Markdown exactly. Adjust asset paths only to remain valid from the chunk directory. Do not insert a Segmenter summary.

## Index

List chunks in reading order with ID, title, section, pages, role, and dependencies. Link to each chunk using a relative Markdown link. The index is navigation, not a replacement for `chunk-map.json`.

## Size

Do not enforce a fixed token count. A useful chunk is small enough for focused questioning and large enough to contain one complete idea. When forced to choose, preserve semantic integrity over equal sizes.
