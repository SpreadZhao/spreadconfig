# Note Patch

## Target

- Note: `Projects/leetcode/<num> <title>.md`
- Problem: `<num> <title>`
- Language: `<language>`
- Session: `<session_dir>`

## Front matter changes

```yaml
mtrace:
  - <today>
implementations:
  <language>:
    - repo: SpreadStudy
      path: <code path>
      symbol: <symbol>
      last_practiced: <today>
      status: accepted
```

## Body changes

### Insert / update section

```markdown
## <Language> 解法

### <today> <language> attempt

- Run evidence: <summary>
- Main issue or insight: <summary>
- Edge cases: <cases>
```

## Memory updates

```json
[]
```
