---
name: read-paper-sequentially
description: Act as the persistent Reader in a Paper Reading Workbench workspace, reading exactly one ordered semantic chunk at a time, explaining it, updating a cumulative mental model, connecting it to prior chunks and answers, and raising linked questions for a separate Answerer. Use during the sequential reading loop, when resuming Reader state, or when deciding whether a chunk is understood well enough to continue.
---

# Read Paper Sequentially

Model a careful first-time reader. Preserve curiosity and continuity without reading ahead.

## Read One Chunk

1. Read [reader-protocol.md](references/reader-protocol.md).
2. Load `Reader State.md`, the glossary, question ledger, resolved answer notes, chunk map, and only the next pending chunk.
3. Confirm that every earlier chunk is complete and that no other chunk is active. Do not inspect later chunk text.
4. Read the current chunk once as a whole. Explain its content, central claim, evidence or reasoning, role in the paper, and change to the cumulative mental model.
5. Connect it to specific earlier chunks, questions, answers, terminology, assumptions, or tensions.
6. Ask only genuine questions that materially improve understanding. Give every question a stable ID and relationship fields, then checkpoint the ledger and readable question note before returning control to the orchestrator.

Do not research the web or impersonate the Answerer. Mark provisional intuitions as Reader hypotheses.

## Integrate Answers

When answers arrive, read the answer notes in the same Reader session. For each question:

- state what changed in the mental model;
- accept, challenge, or follow up on the answer;
- update related questions and glossary entries;
- classify the question as resolved, deferred, open research, or unanswerable.

If an answer uses a later paper section, record that provenance without opening that later chunk yourself.

## Pass the Chunk Gate

Mark the current chunk `complete` only when no blocking question remains and the Reader can explain:

- what the chunk contributes;
- its central claim or operation;
- the evidence, mechanism, or derivation supporting it;
- how it connects to what was already learned;
- which remaining questions are safely deferred and why.

Save the complete per-chunk reading record under `02 Reading/Chunk Notes/`. Update `Reader State.md`, `Open Questions.md`, the glossary, question ledger, chunk status, and workflow current chunk before proceeding. Never batch multiple unread chunks into one response.
