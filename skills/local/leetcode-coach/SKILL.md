---
name: leetcode-coach
description: Coach SpreadZhao's LeetCode practice across the SpreadStudy code repository and SecondBrain notes. Use when the user asks to pick a LeetCode practice problem, run and review a LeetCode attempt, analyze compile/runtime/wrong-answer failures, provide minimal hints, create session records, generate note patches, or merge multi-language LeetCode learning into one SecondBrain note.
---

# LeetCode Coach

## Purpose

Use this skill for SpreadZhao's Skill-first LeetCode learning loop:

```text
choose problem -> user writes code -> run configured command -> review result and code -> give minimal revision guidance -> rerun -> generate note patch -> record reusable mistakes
```

The workflow is centered on two existing repositories:

- Code reference: `https://github.com/SpreadZhao/SpreadStudy`
- Notes reference: `https://github.com/SpreadZhao/SecondBrain`

The skill source can be exposed by a workspace agent profile, but runtime state
lives under `SpreadStudy/Leetcode/.leetcode-coach/` relative to the workspace
root. It is not owned by NixOS, Home Manager, or spreadconfig activation. Real
local repository paths must come from the runtime `config.yaml`; never guess
paths, scan the home directory, or ask the user for configuration during a
skill action.

## Workspace Scope

- Work with code in the configured SpreadStudy checkout, normally `/home/spreadzhao/workspaces/SpreadStudy`.
- Work with notes in the configured SecondBrain checkout, normally `/home/spreadzhao/workspaces/SecondBrain`.
- Read and write LeetCode coach runtime state only under `/home/spreadzhao/workspaces/SpreadStudy/Leetcode/.leetcode-coach`.
- Do not treat the spreadconfig skill source directory as the LeetCode project root.

## Required First Steps

1. Read the runtime config with `scripts/load_config.py` or by direct inspection.
2. If a required field is missing, report the exact missing field and the config file path, then stop the current action.
3. Use only configured repository paths and configured commands, or a command explicitly supplied in the user's current request.
4. Create or update session artifacts only under the runtime state directory's `sessions/`.
5. Write durable memory only under the runtime state directory's `memory/`.
6. Do not modify SecondBrain notes unless the user explicitly asks to apply a note patch.

## Task Routing

- For repository assumptions and config fields, read `references/repositories.md`.
- For the end-to-end process, read `references/workflow.md`.
- For run evidence and command rules, read `references/run-evidence.md`.
- For code review output, verdicts, and hint limits, read `references/review-rubric.md`.
- For note generation style, read `references/note-style.md`.
- For one-problem-one-note merging, read `references/note-merge-rules.md`.
- For mistake and memory recording, read `references/memory-rules.md`.
- For borrowed product ideas and what not to copy, read `references/open-source-references.md`.

## Core Rules

- Prefer `run_then_review`: run the configured command before final acceptance whenever possible.
- Do not generate a missing runner, test harness, Gradle target, shell script, or local path.
- If no run command is configured and the user did not provide a one-time command, perform static review only and use verdict `cannot_prove_correctness`.
- On failure, classify the failure, summarize key logs, identify likely code locations, state root-cause hypotheses, give minimal modification direction, recommend rerun cases, and record reusable learning.
- Default to minimal hints. Do not provide full final code unless the user explicitly asks for a full solution.
- After a passing run or explicit retrospective request, generate `note-patch.md` rather than directly editing the notes repository.
- Keep one note per problem. Merge C++, Java, Kotlin, or later language attempts into the same problem note.
- Preserve existing manual notes, TODOs, Obsidian links, diagrams, and front matter fields.

## Helper Scripts

Run helpers from the workspace root or from `SpreadStudy/Leetcode`; do not run
them from the spreadconfig repository root because default runtime config
discovery is relative to the current working directory. Treat helpers as
internal skill tools, not a user-facing CLI product.

Resolve helper scripts from the active skill directory:

```bash
SKILL_DIR="<directory containing this SKILL.md>"
"$SKILL_DIR/scripts/run_python_helper.sh" load_config.py --pretty
```

The Python helpers only use standard library modules. On NixOS, do not assume
`python3` is globally available; use `scripts/run_python_helper.sh`, which uses
`python3` from `PATH` when present and falls back to `nix shell nixpkgs#python3`.

- `scripts/load_config.py`: load and validate the runtime config.
- `scripts/write_event.py`: append JSONL events to a session.
- `scripts/scan_notes.py`: scan configured SecondBrain LeetCode notes.
- `scripts/scan_code.py`: scan configured SpreadStudy LeetCode code files.
- `scripts/run_review_command.py`: execute configured or one-time review commands and write run evidence.
- `scripts/extract_frontmatter.py`: extract Markdown front matter without changing files.
- `scripts/merge_note_patch.py`: preview or explicitly apply a generated note patch.
- `scripts/summarize_run_failure.py`: summarize run-result failures into a reusable review/memory seed.

Templates live in `templates/`. Use them as starting structures for config, sessions, run results, review results, note patches, memory records, and weekly reports.
