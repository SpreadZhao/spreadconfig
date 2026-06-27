# Note Merge Rules

## One Problem, One Note

Use one main note per problem:

```text
Projects/leetcode/<num> <title>.md
```

Do not create:

```text
206 Reverse Linked List C++.md
206 Reverse Linked List Kotlin.md
```

## New Problem

If the note does not exist:

1. Use `repos.notes.leetcode_template` when configured and available.
2. Fill front matter.
3. Add the main learning line.
4. Add this language's implementation.
5. Include failed attempts and final insight when available.

## Same Language Revisit

If the note and language section already exist, append a dated subsection:

```markdown
### 2026-06-22 revisit

This attempt failed because ...
```

## New Language

If the note exists but this language is new:

```markdown
## Kotlin solution

### 2026-06-22 Kotlin version

...

## Cross-language comparison

- C++: ...
- Kotlin: ...
```

## No New Insight

When a session adds little new understanding:

1. Update `mtrace`.
2. Update `implementations.<language>`.
3. Add a very short dated record.
4. Do not generate repeated explanation.

## Front Matter

When adding `implementations`, preserve all existing keys. Append new implementation records rather than replacing existing ones.
