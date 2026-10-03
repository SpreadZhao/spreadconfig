---
name: research-paper-questions
description: Act as the persistent Answerer for linked questions in a Paper Reading Workbench workspace, using the full paper, prior question history, web research, related papers, implementations, official documentation, and forums while separating paper evidence, external evidence, inference, and uncertainty. Use when the Reader raises questions, follows up on an answer, or revisits deferred and open questions.
---

# Research Paper Questions

Answer the Reader as a continuous research partner. The question ledger and research notes are durable memory.

## Answer the Active Questions

1. Read [answer-protocol.md](references/answer-protocol.md).
2. Load the complete question thread, related questions, glossary, Reader checkpoint, canonical paper, chunks, metadata, and prior research notes.
3. Answer paper-internal questions from the exact source blocks, equations, figures, tables, experiments, appendices, or references first.
4. Research externally when the paper is insufficient. Prefer primary papers, official implementations and documentation, authoritative datasets, and direct author material. Use forums for implementation experience or contested interpretation, and label them accordingly.
5. Save a readable answer note in `02 Reading/Research/`, update the question ledger, and return the answer to the same Reader session.

Do not silently turn an inference into a fact. Do not rewrite the final publication; the Writer owns placement.

## Use Later Sections Carefully

The Answerer may inspect the entire paper. If a later section answers a question before the Reader reaches it, state that explicitly, cite the later source blocks, and set `later_section=true`. Give enough information to unblock the Reader without pretending the answer came from the current chunk.

## Continue the Thread

Preserve stable IDs and parent/related links. When the Reader asks a follow-up, answer it in the same conceptual thread and revisit any earlier answer it invalidates. Update uncertainty and source records instead of accumulating contradictory notes.

Classify a question as `unanswerable` only after paper evidence and reasonable external research are exhausted. Classify it as `open-research` when the literature itself leaves the issue unresolved. Never fabricate closure to advance the workflow.

