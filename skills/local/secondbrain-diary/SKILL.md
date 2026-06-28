---
name: secondbrain-diary
description: Manage diary notes in the SecondBrain repository. Use when Codex needs to create, update, organize, review, or search diary entries under StudyLogNew/diary, including daily learning logs, technical notes, personal analysis notes, Obsidian image embeds, frontmatter cleanup, tags, mtrace dates, and year-based resource handling.
---

# SecondBrain Diary

## Core Rules

- Work from `/home/spreadzhao/workspaces/SecondBrain`.
- When invoked from a cross-repository workspace session, change into the SecondBrain repo before running git, search, or edit commands.
- This skill owns SecondBrain diary content only; do not write diary runtime files into the spreadconfig skill source directory.
- Check `git status --short` before editing. Preserve unrelated user changes.
- Keep diary entries under `StudyLogNew/diary/<year>/`.
- Name entries `YYYY-MM-DD_slug.md`, where the date is the entry date and the slug is lowercase hyphen-case English when possible.
- Put diary-local resources under `StudyLogNew/diary/<year>/resources/`.
- Use Obsidian wikilinks and embeds, not absolute file links, for notes and local resources.
- Do not create entries in the future unless the user explicitly asks for that date. If the user says today, use the current local date from the environment or `date +%F`.
- Do not overwrite an existing diary file. If a same-day related entry exists, update it when that matches the request; otherwise create a distinct slug.

## Diary Shape

Use this frontmatter shape:

```markdown
---
title: Human Readable Title
date: YYYY-MM-DD
tags:
  - tag
mtrace:
  - YYYY-MM-DD
description: One concise sentence describing the note
---
```

Then start the body with one H1. Use the article title, technical topic, or a concise Chinese title depending on the surrounding diary style.

Common observed patterns:

- Technical notes use explanatory sections, code blocks, command output, and exact references.
- Personal or work analysis notes use Chinese prose, screenshots, and direct observations.
- Source-driven notes start with a "参考：" section or a source link before the main H1 when useful.
- Image embeds use `![[StudyLogNew/diary/<year>/resources/Pasted image YYYYMMDDHHMMSS.png]]`; add a width like `|200` when matching existing screenshot-heavy notes.

## Create Or Update

1. Determine the target date, title, tags, and whether the user wants a new entry or an update.
2. Inspect nearby entries in the same year and topic before writing:
   - `rg --files StudyLogNew/diary/<year>`
   - `rg -n "<topic>|<keyword>" StudyLogNew/diary`
3. Choose tags already used in diary when reasonable. Use slash tags such as `language/coding/go` when the existing notes do.
4. Create the year directory and `resources/` only when needed.
5. Write the note in the user's likely language. Most diary analysis notes are Chinese; technical terms, code, commands, and proper nouns stay literal.
6. Keep the description specific and short. Avoid generic descriptions like "daily note".
7. If updating an entry, keep the existing frontmatter and tone unless the user asked for cleanup.

## Resource Handling

- If the user provides images already in the vault, move or reference them under the matching year `resources/` directory only when asked or clearly necessary.
- If an image file is outside the vault, ask before copying it unless the task explicitly says to archive or embed it.
- Preserve existing pasted-image names unless renaming is requested.
- Use Obsidian embeds for images and normal Markdown links for external URLs.

## Quality Pass

- Run `rg -n "^---$|^title:|^date:|^tags:|^mtrace:|^description:" <file>` for frontmatter sanity on new or heavily edited notes.
- Check that wikilinks point to vault-relative paths and that resource paths include the correct year.
- For generated or summarized content, keep claims traceable to user-provided material or cited sources.
- Report the diary file path changed and any remaining open questions.
