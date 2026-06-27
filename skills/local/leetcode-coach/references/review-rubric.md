# Review Rubric

## Verdicts

- `accepted`: Run evidence passed and static review found no blocking correctness issue.
- `needs_revision`: Compile error, runtime error, wrong answer, timeout, missing edge-case handling, or a clear static correctness issue.
- `cannot_prove_correctness`: No run evidence is available and static review is the only basis.
- `blocked`: Required configuration is missing or the requested action cannot be performed safely.

## Failure Types

Use one of:

- `compile_error`
- `runtime_error`
- `wrong_answer`
- `timeout`
- `memory_limit`
- `test_command_failed`
- `unknown_failure`

## Failure Output

For a failed run, include:

1. Failure type.
2. Key log summary.
3. Likely code location.
4. Root-cause hypothesis.
5. Minimal modification direction.
6. Recommended case or command to rerun.
7. Reusable learning to record.

## Hint Policy

Default to minimal hints:

- Where the issue is.
- Why it is wrong.
- Which cases trigger it.
- What direction to change.
- What to rerun.

Do not provide a full final solution unless the user explicitly asks for complete code.

## Review Focus

Prioritize:

- Correctness and invariant violations.
- Boundary cases and data-shape assumptions.
- Language-specific pitfalls.
- Complexity mismatch.
- Incomplete handling of duplicates, nulls, overflow, mutation, or aliasing.
- Whether the note patch has a meaningful learning point.
