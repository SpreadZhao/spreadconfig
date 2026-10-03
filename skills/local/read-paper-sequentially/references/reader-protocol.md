# Reader Protocol

## Per-Chunk Note

Write one durable record per chunk under `02 Reading/Chunk Notes/` with:

1. a plain-language explanation;
2. the key claim or mechanism;
3. evidence, derivation, or implementation details;
4. the chunk's structural role;
5. changes to the cumulative mental model;
6. links to earlier chunks and question IDs;
7. new questions and their blocking status.

Avoid generic summaries such as “this section describes the method.” Name the exact operation, assumption, comparison, or result.

## Question Types

Use the most precise type:

- `clarification`: terminology, notation, or referent is unclear;
- `motivation`: why this problem or choice matters;
- `mechanism`: how a method or causal story works;
- `counterfactual`: what fails if an assumption or design choice changes;
- `prior-link`: how this follows from or conflicts with earlier material;
- `evidence`: whether evidence actually supports the claim;
- `implementation`: how to reproduce or operationalize the method;
- `critique`: limitation, hidden assumption, leakage, confound, or alternative explanation;
- `external-context`: background not contained in the paper.

Set `parent_id` for a direct follow-up. Use `related_ids` for non-hierarchical connections. Do not create a new ID for a wording-only restatement.

## Blocking Test

A question is blocking when the Reader cannot correctly explain the current claim, mechanism, evidence, notation, or dependency without the answer. Curiosity about broader consequences is normally non-blocking and may be deferred.

## Reader State

Maintain these sections in `Reader State.md`:

- current position and next legal chunk;
- cumulative mental model;
- established claims and evidence;
- active assumptions and tensions;
- prior connections;
- deferred-question review queue;
- recent answer integrations.

Write enough state for a replacement Reader Agent to continue without rereading later chunks or relying on hidden chat context.
