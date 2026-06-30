---
name: secondbrain-conversation-diary
description: Conversational diary workflow for turning free-form chats into SecondBrain diary notes. Use when the user wants to talk through thoughts, experiences, technical progress, decisions, emotions, or reflections and later save the conversation as a new diary entry or append it to an existing diary entry in the SecondBrain repository. Use external research and links when public context, similar discussions, papers, forums, videos, news, or technical references would improve the conversation or diary. Search existing SecondBrain or Obsidian notes when related vault context could enrich the conversation or diary.
---

# SecondBrain Conversation Diary

## Overview

Use this skill as an umbrella workflow above `secondbrain-diary`. Support open-ended conversation first, then turn the conversation into a structured diary note only when the user explicitly asks to save it.

Do not reimplement repository layout, filename rules, frontmatter rules, resource handling, Obsidian wikilink style, or quality checks. When writing files, load and follow `secondbrain-diary`.

## Workspace Scope

- During conversation, do not assume the current working directory is the target notes repo.
- When saving, delegate repository writes to `secondbrain-diary`, whose target repo is `/home/spreadzhao/workspaces/SecondBrain`.
- Keep temporary reasoning in the conversation only; do not create runtime state under the spreadconfig skill source.

## Dependent Skills

- Use this skill to guide the conversation, identify diary-worthy material, and build a Diary Packet.
- Use `secondbrain-diary` to inspect the SecondBrain repository, choose create versus update, write the note, handle resources, and run quality checks.
- When available, use Obsidian skills such as `obsidian-cli` for vault search and note lookup, and `obsidian-markdown` for Obsidian wikilinks and note syntax.
- If the user explicitly names `secondbrain-diary`, still treat this skill as the conversational umbrella when the task begins from a free-form chat.

## Conversation Mode

- During ordinary conversation, do not create or modify diary files.
- Only write when the user explicitly asks to save, write, record, archive, append, supplement, revise, or update a diary.
- Act as a thinking partner, not a passive summarizer.
- Proactively search for external context when the topic has public facts, technical details, community practice, current events, comparable experiences, papers, forum discussions, videos, news, or other references that would make the conversation and later diary more grounded.
- When external research is used, include useful links in the visible answer and keep those sources available for the Diary Packet.
- Proactively search existing SecondBrain or Obsidian notes when the topic may connect to prior diary entries, projects, decisions, people, concepts, books, articles, technical investigations, or unresolved questions.
- When related notes are found, use them as context for the conversation and mention useful internal note links where appropriate.
- Do not over-research purely private reflection unless the user asks for it or outside context would clearly help. Personal facts still come from the conversation, not from external sources.
- Ask targeted follow-up questions only when they improve diary quality.
- Track events, technical progress, decisions, unresolved questions, changes of opinion, personal reflections, and relevant active projects.
- Preserve the user's language and tone. Prefer Chinese prose for Chinese conversations unless the source conversation is mainly English or code-heavy.
- Do not invent events, conclusions, emotions, or project context that were not present in the conversation.

## Diary Packet

Before invoking `secondbrain-diary`, convert the conversation into this reasoning and working structure:

```yaml
date: YYYY-MM-DD
action: create | update | uncertain
candidate_title:
topic:
star: false
summary:
transcript_scope: full | partial
full_conversation_transcript:
  - role: user | assistant
    content: |
key_events:
technical_details:
decisions:
open_questions:
personal_reflection:
external_sources:
  - title:
    url:
    type: paper | forum | docs | issue | blog | video | news | social | other
    relevance:
related_discussions:
source_notes:
related_notes:
  - title:
    path:
    wikilink:
    relevance:
    useful_excerpt:
note_context_summary:
suggested_tags:
target_existing_entry:
confidence:
```

Use the packet to make the write decision and communicate intent to `secondbrain-diary`. `full_conversation_transcript` must preserve every in-scope user message and every visible assistant reply in order before summarization.

`external_sources`, `related_discussions`, `source_notes`, `related_notes`, and `note_context_summary` are supporting context gathered before invoking `secondbrain-diary`. They must not replace the transcript, and they must not be used to invent user experiences, decisions, or emotions.

Set `star: true` only when the user explicitly asks to star, favorite, highlight, pin, or put the diary in the Star section; otherwise keep `star: false`.

## Transcript Preservation

When saving a conversation diary, preserve the complete visible conversation first, then add a summary and interpretation.

- Include a `## 完整对话记录` or equivalent section in the diary note.
- Preserve the user's full messages and the assistant's full visible answers, including code blocks, command snippets, links, lists, and important wording.
- Label turns clearly, for example `**用户：**` and `**AI：**`. If a model or assistant name is explicitly known from visible context, include it; otherwise do not invent one.
- After the transcript, include a `## 总结` or topic-specific summary section that extracts events, decisions, technical progress, unresolved questions, and reflections from the transcript.
- Do not replace the transcript with a summary unless the user explicitly asks for a summary-only diary.
- Do not save hidden chain-of-thought, internal reasoning traces, raw tool logs, or content that was not shown to the user. Summarize reasoning instead.
- If the complete conversation is not available in the current context, ask the user for the missing transcript or ask whether a clearly labeled partial record is acceptable. Do not present a partial transcript as complete.

## External Context Research

Use external research as part of the conversation whenever it can improve factual grounding, surface similar discussions, or add useful context for the future diary.

- Before giving a definitive answer about public, technical, current, or disputed matters, search for relevant sources instead of relying only on model memory.
- Look for similar discussions and concrete references across official documentation, papers or preprints, forums, GitHub issues, blogs, videos, news, and social or community posts.
- Prefer primary or authoritative sources for factual claims. Use forums, issues, videos, and community discussions to capture practical experience, tradeoffs, and disagreement.
- Cite direct links in the visible answer when external sources shape the response.
- Keep source use proportional. A casual private feeling may not need research; a technical decision, tool behavior, public event, product issue, or common experience usually benefits from it.
- If no useful source is found, or browsing is unavailable, say that clearly. Do not fabricate links, titles, publication details, or community consensus.
- For diary writing, add an `## 外部参考`, `## 相关讨论`, or equivalent section when sources materially informed the conversation. Keep it separate from `## 完整对话记录` and `## 总结`.
- Clearly distinguish the user's own experience from outside context. External sources can support interpretation, but they cannot prove what the user felt, intended, or experienced.

## Existing Note Context

Use the existing SecondBrain vault as a private context source when it can make the conversation or saved diary more connected to the user's prior knowledge.

- Search existing notes by topic keywords, project names, tool names, people, dates, decisions, tags, and likely aliases.
- Prefer Obsidian tooling when available. Load and follow `obsidian-cli` for vault search or note lookup, and `obsidian-markdown` when generating wikilinks or referencing note structure.
- If Obsidian is not running or the Obsidian CLI is unavailable, fall back to repository or filesystem search only when the vault path is available and doing so is safe.
- Use related notes to remind the user of prior context, surface contradictions or continuity, and identify whether the current conversation extends an existing thread.
- In visible conversation, cite related notes with Obsidian wikilinks such as `[[Note Title]]` when the title is known. Include paths only when useful for disambiguation.
- In the Diary Packet, record related notes with title, path, wikilink, relevance, and a short useful excerpt or summary.
- For diary writing, add a `## 关联笔记`, `## 相关笔记`, or equivalent section when existing notes materially informed the result.
- Do not dump large private note contents into the answer or diary. Quote only the minimal excerpt needed, and summarize the rest.
- Do not modify related notes unless the user explicitly asks to update those notes. This skill only uses them as context unless a separate write request is made.

## Create Or Update Decision

Prefer update when:

- the user says append, supplement, revise, continue, or update;
- a same-day diary entry already covers the same topic;
- the conversation clearly continues an existing note.

Prefer create when:

- the conversation is a distinct topic;
- no same-day related diary exists;
- the user asks for a separate note.

If uncertain:

- inspect nearby diary entries through `secondbrain-diary` conventions;
- choose the least destructive option;
- do not overwrite unrelated content.

## Writing Mode

When the user asks to save:

1. Convert the current conversation into a Diary Packet.
2. Search existing SecondBrain or Obsidian notes for related private context when prior notes could improve continuity.
3. Collect or refresh relevant external sources when public context, similar discussions, or references would improve the diary.
4. Load and follow `secondbrain-diary`.
5. Search existing diary entries by date and topic.
6. Decide whether to create or update.
7. Write the note using `secondbrain-diary` rules, preserving the complete visible transcript, then adding the summary, related-note section, and any external-reference section.
8. Run the checks required by `secondbrain-diary`.
9. Report the changed file path and whether it was created or updated.

## Update Style

When appending to an existing note:

- keep existing frontmatter unless cleanup is requested;
- add a clear section such as `## 追加记录`, `## 今日补充`, `## 后续思考`, `## 完整对话记录`, or a topic-specific heading;
- merge into an existing section only when the new material directly expands it;
- avoid duplicated summaries;
- do not duplicate an existing full transcript unless the new conversation materially extends it. Add only the new turns and summary when appending a continuation.

## Conversation Quality

Use these guiding questions to improve the conversation and later diary entry:

- What happened?
- Why did it matter?
- What changed in the user's understanding?
- What decision was made?
- What remains unresolved?
- What should be revisited later?

Do not force all questions every time. Ask only the questions that fit the moment and would materially improve the future diary note.

## Safety And Boundaries

- Do not write diary entries containing unsupported claims.
- Treat external sources as context, not evidence for the user's private internal state.
- Treat existing notes as private context, not absolute truth. If current conversation conflicts with an older note, preserve the change instead of silently normalizing it away.
- Do not present low-quality or disputed sources as settled fact. Label disagreement and uncertainty.
- Do not expose hidden chain-of-thought; summarize reasoning instead.
- Do not treat casual conversation as consent to write a diary.
- If the user asks for a diary about a sensitive personal topic, keep the wording grounded, non-dramatic, and user-controlled.
- For sensitive personal topics, use external research carefully and only when it helps the user. Avoid over-medicalizing, pathologizing, or expanding the scope beyond what the user asked for.
- If the user asks to remove or revise personal material, obey that request.

## Final Report

After saving, report:

- the file path changed;
- whether the note was created or updated;
- the title or topic used;
- checks run through `secondbrain-diary`;
- any unresolved questions or assumptions.
