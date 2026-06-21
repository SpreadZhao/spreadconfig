---
name: wechat-diary
description: Umbrella workflow for turning WeChat public account articles into SecondBrain diary notes. Use when the user provides an mp.weixin.qq.com article and asks to write it as a diary, archive it into StudyLogNew/diary, include downloaded images, and add Codex's understanding inline with the article content.
---

# WeChat Diary

## Overview

Use this skill to coordinate the existing `wechat-article-fetcher` and `secondbrain-diary` skills. Do not reimplement article fetching or diary conventions here; load and follow those skills when available, then apply the integration rules below.

## Dependent Skills

- Use `wechat-article-fetcher` to fetch the article Markdown and local images.
- Use `secondbrain-diary` to choose the diary path, frontmatter shape, resource directory, and Obsidian link style.
- If the user explicitly names either dependent skill, still treat this skill as the umbrella workflow that orders them.

## Workflow

1. Check repository state before editing and preserve unrelated user changes.
2. Fetch the WeChat article into a temporary Markdown file with images downloaded locally.
3. Read the fetched article before writing. Use the article title, source URL, author, structure, images, and tables as source material.
4. Create or update one diary note under `StudyLogNew/diary/<year>/`; do not create a separate raw article note.
5. Copy article images into `StudyLogNew/diary/<year>/resources/` with deterministic names such as `wechat_<article-id>_image01.png`.
6. Rewrite image references as Obsidian embeds using repository-root paths, for example `![[StudyLogNew/diary/2026/resources/wechat_<id>_image01.png]]`.
7. Preserve the article's useful content, section order, examples, tables, and references. Remove only obvious WeChat UI chrome and unrelated recommendation blocks.
8. Add Codex's understanding near the paragraphs or sections it explains, usually as `> [!note] 我的理解` callouts. Do not put all understanding in a separate second document.
9. Relate the article to the user's active projects or recurring themes when there is clear context from nearby notes, but keep claims traceable to the article or local notes.

## Diary Shape

Use the current local date unless the user asks for another date. Prefer a concise English slug that describes the article topic, for example:

```text
StudyLogNew/diary/2026/2026-06-22_loop-engineering-loop-vs-goal.md
```

Use this structure:

```markdown
---
title: Human Readable Title
date: YYYY-MM-DD
tags:
  - ai
mtrace:
  - YYYY-MM-DD
description: One concise sentence
---

参考：

- 原文：[Article Title](https://mp.weixin.qq.com/s/...)

# Article-Or-Topic Title
```

Choose tags from nearby diary notes when possible. Use Chinese prose for the diary body unless the surrounding note style or source material clearly suggests otherwise.

## Integration Rules

- Keep article content and Codex understanding in the same diary note.
- Put `我的理解` callouts immediately after the relevant article section.
- Prefer a few high-signal callouts over a comment after every paragraph.
- Preserve useful article images and captions; skip only decorative or recommendation-only images when they do not support the note.
- Keep Markdown tables readable and do not rewrite the user's or article author's phrasing unless cleanup is necessary.
- When adding local resources, follow repository attachment rules: folder name `resources`, under the current diary year folder, linked from the repository root.

## Quality Pass

Before finishing:

- Check frontmatter fields with `rg`.
- Check there are no remaining remote WeChat image links or temporary asset paths.
- Check image embed count against copied resource count when images were downloaded.
- Check `git status --short` and report only files created or changed for this workflow.
