# Repository And Config Rules

## Fixed Remote References

- Code repository: `https://github.com/SpreadZhao/SpreadStudy`
- Notes repository: `https://github.com/SpreadZhao/SecondBrain`

These remotes describe the intended ecosystem. Runtime work must use local paths
from `SpreadStudy/Leetcode/.leetcode-coach/config.yaml` when running from the
workspace root, or `.leetcode-coach/config.yaml` when running from
`SpreadStudy/Leetcode`. This file is runtime state and must not be generated or
managed by NixOS/Home Manager.

Do not use the spreadconfig skill source directory as a runtime root. If the
skill is loaded from `/home/spreadzhao/workspaces/.agents/skills/leetcode-coach`
or `/home/spreadzhao/workspaces/spreadconfig/skills/local/leetcode-coach`, keep
using the configured SpreadStudy and SecondBrain paths for real work.

## Expected Code Shape

Known reference paths in SpreadStudy:

- `SpreadStudy/Leetcode/LeetcodeCpp/Questions/Solution.h`
- `SpreadStudy/Leetcode/LeetcodeCpp/Questions/Solution.cpp`
- `SpreadStudy/Leetcode/LeetcodeJava/src/questions/*.java`
- `SpreadStudy/Leetcode/LeetcodeJava/src/questions/*.kt`

Treat these as examples only. Do not assume the local checkout path.

## Expected Notes Shape

Known reference paths in SecondBrain:

- `SecondBrain/Projects/leetcode`
- `SecondBrain/templates/leetcode.md`

Notes are personal learning records, not official editorials. Preserve failure attempts, TODOs, Obsidian links, diagrams, and manual wording.

## Runtime Config

Read the runtime config for:

- `repos.code.local_path`
- `repos.code.leetcode_root`
- `repos.notes.local_path`
- `repos.notes.leetcode_notes`
- `repos.notes.leetcode_template`
- `languages.<language>.run_command`
- `languages.<language>.cwd`
- `languages.<language>.source_root`

The config may be edited manually as the user's workflow changes. The skill
source only provides templates and helper scripts.

If a required value is blank or missing, stop the current action with a concrete error:

```text
Cannot run review command: languages.cpp.run_command is empty.

Fill this field in the runtime config, or provide a one-time command in the current request.
The skill will not guess paths or generate a runner.
```

Do not scan `$HOME`, `/Users`, `/home`, parent directories, IDE workspaces, or shell history to discover repositories.
