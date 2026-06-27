# Workflow

## Choose A Problem

1. Load config.
2. Scan configured SecondBrain LeetCode notes.
3. Read `mtrace`, TODOs, tags, and existing implementations.
4. Read runtime memory JSONL files.
5. Scan configured SpreadStudy LeetCode code roots.
6. Recommend one problem with explicit evidence.
7. Create a session under the runtime state directory's `sessions/<problem-slug>/<date-language>/`.

If evidence is weak, say so. Do not invent a problem source or fake a spaced-repetition score.

## Run And Review

1. Load config.
2. Locate the code file from the user's request or configured language roots.
3. Locate the existing problem note when config permits.
4. Run `languages.<language>.run_command` or a one-time command from the current request.
5. Capture exit code, stdout, stderr, duration, failed case, and failure type.
6. Read the submitted code and relevant note context.
7. Combine run evidence and static review into `review-result.json`.
8. If the run failed, write session events and memory candidates before giving guidance.
9. If the run passed, still inspect complexity, edge cases, language pitfalls, and new insights.

## Static Review Fallback

When no configured or one-time run command exists:

1. Do not generate a runner.
2. Review the code statically.
3. Set `run_evidence.available` to `false`.
4. Use verdict `cannot_prove_correctness`.
5. Say: "Static review did not find an obvious issue, but without run evidence correctness is not proven."

## Note Patch

Generate a note patch after a passing run or an explicit retrospective request:

1. Read session artifacts.
2. Read the target problem note if available.
3. Decide whether this is a new problem, same-language revisit, or new-language implementation.
4. Write the note patch under the runtime session directory.
5. Do not edit SecondBrain unless the user explicitly asks to apply the patch.
