# Run Evidence

## Allowed Command Sources

Use exactly one of:

1. `languages.<language>.run_command` from the runtime config.
2. A one-time command explicitly provided in the user's current request.
3. An existing repository script only when config clearly points at it or the user explicitly allows it.

Do not generate a runner, infer a test target, or create a build script because a command is missing.

## Template Variables

Supported command and cwd variables:

- `{problem_num}`
- `{problem_title}`
- `{language}`
- `{code_file}`
- `{code.local_path}`
- `{notes.local_path}`
- `{code.leetcode_root}`
- `{session_dir}`

## Evidence To Capture

- Command.
- Working directory.
- Exit code.
- Duration in milliseconds.
- Stdout summary.
- Stderr summary.
- Failure type.
- Failed case when detectable.

## Missing Command Behavior

If no run command is available, stop the run action and produce a static-review-only path:

```json
{
  "verdict": "cannot_prove_correctness",
  "run_evidence": {
    "available": false
  }
}
```
