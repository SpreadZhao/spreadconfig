---
name: wechat-diary
description: Umbrella workflow for turning WeChat public account articles into SecondBrain diary notes. Use when the user provides an mp.weixin.qq.com article and asks to write it as a diary, archive it into StudyLogNew/diary, include downloaded images, and add Codex's understanding inline with the article content.
---

# WeChat Diary

## Overview

Use this skill to coordinate the existing `wechat-article-fetcher` and `secondbrain-diary` skills. Do not reimplement article fetching or diary conventions here; load and follow those skills when available, then apply the integration rules below.

## Workspace Scope

- Final diary edits belong in `/home/spreadzhao/workspaces/SecondBrain`.
- Fetch raw article Markdown into a temporary path first; copy only selected images and final diary content into the SecondBrain diary tree.
- Do not create raw article archives or resource folders under the spreadconfig skill source directory.

## Dependent Skills

- Use `wechat-article-fetcher` to fetch the article Markdown and local images.
- Use `secondbrain-diary` to choose the diary path, frontmatter shape, resource directory, and Obsidian link style.
- Use the same external-context and existing-note standards as `secondbrain-conversation-diary`, adapted to source-driven WeChat article notes.
- If the user explicitly names either dependent skill, still treat this skill as the umbrella workflow that orders them.

## Workflow

1. Check repository state before editing and preserve unrelated user changes.
2. Fetch the WeChat article into a temporary Markdown file with images downloaded locally.
3. Read the fetched article before writing. Use the article title, source URL, author, structure, images, and tables as source material.
4. Search existing SecondBrain or Obsidian notes for related private context when the article topic may connect to prior diary entries, projects, decisions, people, concepts, books, articles, technical investigations, or unresolved questions.
5. Collect or refresh relevant external sources when the article involves public facts, technical details, current events, community practice, comparable discussions, official documentation, papers, issues, blogs, videos, news, or social/community references that would make the diary more grounded.
6. Create or update one diary note under `StudyLogNew/diary/<year>/`; do not create a separate raw article note.
7. Copy article images into `StudyLogNew/diary/<year>/resources/` with deterministic names such as `wechat_<article-id>_image01.png`.
8. Rewrite image references as Obsidian embeds using repository-root paths, for example `![[StudyLogNew/diary/2026/resources/wechat_<id>_image01.png]]`.
9. Preserve the article's useful content, section order, examples, tables, and references. Remove only obvious WeChat UI chrome and unrelated recommendation blocks.
10. Add Codex's understanding near the paragraphs or sections it explains, usually as `> [!note] 我的理解` callouts. Do not put all understanding in a separate second document.
11. Relate the article to the user's active projects or recurring themes when there is clear context from nearby notes, but keep claims traceable to the article, external sources, or local notes.

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

## External Context Research

Use external research as part of WeChat diary writing whenever it can improve factual grounding, surface similar discussions, or add useful context for the future note.

- Before making definitive claims about public, technical, current, or disputed matters, search for relevant sources instead of relying only on model memory or the WeChat article.
- Look for concrete references across official documentation, papers or preprints, forums, GitHub issues, blogs, videos, news, and social or community posts.
- Prefer primary or authoritative sources for factual claims. Use forums, issues, videos, and community discussions to capture practical experience, tradeoffs, and disagreement.
- Cite direct links in the diary when external sources shape the writing.
- Keep source use proportional, but for technical articles default to adding at least a small `## 外部参考` or `## 相关资料` section when useful sources are available.
- If no useful source is found, or browsing is unavailable, say that clearly. Do not fabricate links, titles, publication details, or community consensus.
- Clearly distinguish the WeChat article's claims from external context. External sources can support interpretation, but they must not be used to silently rewrite the article author's position.

## Existing Note Context

Use the existing SecondBrain vault as private context when it can make the WeChat diary more connected to the user's prior knowledge.

- Search existing notes by topic keywords, project names, tool names, people, dates, decisions, tags, and likely aliases.
- Prefer Obsidian tooling when available. If Obsidian is unavailable, fall back to repository or filesystem search only when the vault path is available and doing so is safe.
- Use related notes to surface continuity, contradictions, prior learning, active projects, and unresolved questions.
- In the diary, cite related notes with Obsidian wikilinks such as `[[Note Title]]` when the title is known.
- Add a `## 关联笔记`, `## 相关笔记`, or equivalent section when related notes materially informed the result.
- Do not dump large private note contents into the diary. Quote only the minimal excerpt needed, and summarize the rest.
- Do not modify related notes unless the user explicitly asks to update those notes.

## Integration Rules

- Keep article content and Codex understanding in the same diary note.
- Put `我的理解` callouts immediately after the relevant article section.
- Prefer a few high-signal callouts over a comment after every paragraph.
- Add external-reference and related-note sections when they materially improve the diary; keep them separate from the article body and clearly trace claims to the article, external sources, or local notes.
- Preserve useful article images and captions; skip only decorative or recommendation-only images when they do not support the note.
- Keep Markdown tables readable and do not rewrite the user's or article author's phrasing unless cleanup is necessary.
- When adding local resources, follow repository attachment rules: folder name `resources`, under the current diary year folder, linked from the repository root.

## Quality Pass

Before finishing:

- Check frontmatter fields with `rg`.
- Check there are no remaining remote WeChat image links or temporary asset paths.
- Check image embed count against copied resource count when images were downloaded.
- Check external links and related-note wikilinks when those sections were added.
- Check `git status --short` and report only files created or changed for this workflow.
