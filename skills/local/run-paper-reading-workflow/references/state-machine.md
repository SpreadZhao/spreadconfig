# Workflow State Machine

Advance `.paper-reading/workflow.json` only after the phase output validates.

1. `initialized`: folder and empty ledgers exist.
2. `ingested`: `ingest=complete`; original, canonical paper, source map, assets, metadata, and extraction report exist.
3. `segmented`: `segment=complete`; chunks form an exact ordered source partition.
4. `drafted`: `bilingual_draft=complete`; the Writer has produced the full source-language and Chinese edition before question enrichment.
5. `reading`: `sequential_reading=in_progress`; `current_chunk_id` identifies the sole active chunk.
6. `publishing`: all chunks are complete; deferred questions are being revisited and Writer placements finalized.
7. `complete`: all phases except validation are complete, final validation passes, then `validation=complete`.

Use `pending`, `in_progress`, `complete`, or `blocked` inside `phases`. A blocked phase must record the reason in `.paper-reading/logs/` and preserve all prior outputs.

On resume, trust validated files over prose claims. If the phase claims more progress than artifacts prove, move the phase back to the last valid boundary and record the repair. If a persistent Agent session is lost, create a replacement role session from its checkpoint without changing IDs or rereading out of order.

Only request user input for a true boundary: inaccessible or unauthorized source, unrelated output-folder collision, materially ambiguous paper identity, or a choice that changes requested scope.
