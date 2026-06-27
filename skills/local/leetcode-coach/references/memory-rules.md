# Memory Rules

Failures are learning material.

## Session First

Write evidence and candidates to the active session before durable memory:

- `events.jsonl`
- `run-result.json`
- `review-result.json`
- `note-patch.md`
- `snapshots/attempt-*.ext`

## Durable Memory

Use the runtime state directory's `memory/`:

- `mistakes.jsonl`: reusable problem-solving mistakes.
- `concepts.jsonl`: concepts or patterns to revisit.
- `language-pitfalls.jsonl`: C++, Java, Kotlin, or later language pitfalls.
- `review-schedule.jsonl`: spaced-review cues.

Only write durable memory when the lesson is reusable beyond the current run.

## Good Memory Candidate

```json
{
  "problem": "15",
  "title": "3 Sum",
  "language": "cpp",
  "type": "two-pointers-duplicate-handling",
  "failure_type": "wrong_answer",
  "symptom": "valid triplet duplicated in output",
  "root_cause": "left/right pointers moved once after recording an answer without skipping equal values",
  "fix": "skip duplicate values for both pointers after recording an answer"
}
```

Keep records factual and tied to run evidence. Avoid vague memories like "be careful".
