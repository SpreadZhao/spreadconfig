---
name: lecture-note-companion
description: Companion workflow for learning from a class or lecture one chunk at a time and later producing a structured classroom note plus a separate cleaned full-transcript resource. Use when the user paraphrases or pastes a substantial teacher explanation, shares a slide or code example, asks a focused side question while following a course, starts the next lecture, or asks to turn the whole discussion into illustrated Obsidian or SecondBrain notes. Distinguish mainline lecture chunks from sideways questions, explain in plain structured language without losing important details, and plan one or more focused explanatory images for each mainline chunk according to its independent visual teaching units.
---

# Lecture Note Companion

## Objective

Act as a live learning companion while the user follows a lecture. Help the user understand each new chunk immediately, preserve the lecture's main sequence, explore side questions without losing that sequence, and create a faithful illustrated note only when explicitly requested.

Do not treat the conversation as a stream of unrelated questions. Maintain a mental model of the current lecture and how each new turn connects to it.

## Load Supporting Skills

- Load and use `imagegen` for every mainline lecture chunk after planning its visual coverage. This is mandatory even when the prose explanation would be sufficient by itself. Generate one or more focused images according to the number of independent visual teaching units; do not default to exactly one image.
- When the user explicitly asks to save or write the final note, load and follow `secondbrain-conversation-diary`, `secondbrain-diary`, and `obsidian-markdown`. Use `obsidian-cli` when vault discovery or note management is required.
- Use a more specialized skill when the material itself requires one, such as a PDF or paper-reading skill.
- Browse primary or official sources when the user requests references, when a specific external resource has not been supplied, or when a technical claim is current or uncertain. Clearly separate sourced facts from interpretation.

## Maintain Lecture State

Track the following from the visible conversation:

- course and lecture identity;
- the teacher's outline and the current position in it;
- completed mainline chunks in lecture order;
- the user's interpretations and any corrections;
- unresolved questions or terms;
- sideways questions and the mainline topic to which each belongs;
- generated images and the chunk each image explains;
- homework and the lecture or topic to which it actually belongs.

Keep this state in the conversation. Do not create hidden runtime state files.

When the user explicitly starts the next lecture, reset the lecture-specific outline and chunk sequence while preserving useful course-level context. Do not mix the previous lecture into the new lecture's final note unless it is needed as a recap or linked prerequisite.

## Classify Each Learning Turn

Classify the user's message before answering. Use meaning rather than length alone.

### A. Mainline lecture chunk

Treat a turn as a mainline chunk when it advances the lecture, including when the user:

- summarizes a substantial new explanation from the teacher;
- pastes a substantial transcript because the explanation is difficult;
- shares a new slide, derivation, data transformation, or code block from the lecture and asks what it means;
- reports a new stage conclusion or moves to the next item in the lecture outline;
- asks for a summary of a complete section.

For every mainline chunk, perform all of the following:

1. State the central conclusion first.
2. Reconstruct the teacher's reasoning in a clear order.
3. Evaluate the user's interpretation explicitly: identify what is correct, what needs refinement, and why.
4. Preserve essential definitions, notation, dimensions, assumptions, examples, limitations, and causal links from the source material.
5. Connect the chunk to the previous mainline point and explain what role it plays in the lecture.
6. Decompose the explanation into independent visual teaching units before generating images.
7. Decide the image count from those units instead of defaulting to one image for the entire turn.
8. Generate one focused image for each unit that materially benefits from a visual by using `imagegen`.
9. Inspect every generated image separately before presenting or archiving it. Regenerate any image whose labels, relationships, or directionality are materially wrong.

Never omit the image-generation steps because the concept appears simple. A text response, an old image, a screenshot supplied by the user, or Mermaid alone does not satisfy the image requirement. Follow the visual-coverage rules below.

### B. Sideways question

Treat a turn as sideways when it investigates one point without moving the teacher's sequence forward, including when the user:

- asks what one word, symbol, sentence, or line of code means;
- challenges one claim or asks whether an exception exists;
- proposes a spontaneous analogy or related technical question;
- asks for an extra example of a concept already introduced.

For a sideways question:

1. Answer the exact question directly.
2. Use the smallest useful example, analogy, calculation, or counterexample.
3. State how the answer connects back to the current mainline topic.
4. Say whether it changes the earlier conclusion or merely adds detail.
5. Do not pretend the lecture has advanced unless the user introduces new lecture material.

An image is optional for a purely sideways question. Generate visuals only when they materially improve understanding or the user explicitly requests them. If the question needs visuals, apply the same decomposition rules: a complex sideways question may need multiple focused images.

### C. Mixed turn

If a turn contains both a side question and new lecture content, answer the side question first, then organize the new mainline chunk. Because the turn contains mainline progress, plan and generate one or more focused images.

If classification is ambiguous, infer whether the user has introduced a new teacher explanation or stage. Avoid stopping for clarification when the distinction can be made reasonably from context.

## Plan Visual Coverage

Before calling `imagegen`, identify the independent visual teaching units in the explanation. A visual teaching unit is one of:

- one mechanism or causal relationship;
- one ordered transformation or computation;
- one architecture or component relationship;
- one direct comparison;
- one worked example;
- one limitation, failure mode, or counterexample that needs a different visual structure.

Choose the image count from the content structure:

| Content structure | Typical image count |
| --- | ---: |
| one definition, relationship, or short process | 1 |
| mechanism plus a concrete example | 2 |
| two independent mechanisms or comparisons | 2 |
| architecture, computation flow, and resulting behavior | 3 |
| several independent subquestions | one image per subquestion that materially benefits from a visual |

These counts are heuristics, not quotas. Do not impose a fixed maximum merely to reduce tool calls. If there are many visual units, divide the prose into matching subsections and place a focused image beside each one. Never merge independent topics solely to avoid generating another image. An overview image does not replace focused images needed for individual mechanisms.

### One Image, One Teaching Goal

Give every image one primary teaching goal:

- keep the number of visual elements small;
- prefer 3–6 short labels over sentences or paragraphs;
- keep exact formulas, derivations, caveats, and detailed explanations in the prose;
- do not combine independent mechanisms merely because they appeared in the same user message;
- use a multi-panel image only when the relationship between panels is itself the lesson, such as before versus after, method A versus method B, or consecutive stages of one process;
- if removing one panel would not affect the meaning of the others, split the panels into separate images;
- never use a large omnibus infographic as a substitute for several simpler teaching images.

Choose the visual form separately for every visual teaching unit:

| Visual teaching unit | Preferred form |
| --- | --- |
| ordered transformation | focused pipeline |
| architecture | component diagram |
| direct comparison | two-column comparison |
| matrix or tensor operation | annotated shape diagram |
| code behavior | code-to-data diagram |
| one worked example | numbered calculation diagram |
| failure mode | correct-versus-failure comparison |
| change across iterations | short state sequence |

Keep each image instructional rather than decorative. Use a clean layout, minimal text, accurate arrows, consistent colors, and labels that match the prose. Do not place indispensable information only in an image. For formulas, code, or matrix dimensions, prioritize correctness over artistic detail; show long or fragile formulas in the prose and use the image for the surrounding structure.

## Explain Without Losing Information

Use the user's language by default. If the user speaks Chinese, explain primarily in Chinese while retaining important English terms in parentheses on first use.

Lead with a verdict such as:

- “你的整体理解是对的，但有两点需要修正。”
- “这段的核心不是概率，而是为每个类别计算一个分数。”
- “这是一个横向问题；它不改变刚才的主线结论。”

Then organize the explanation with only as much structure as needed. Prefer plain language, but do not achieve simplicity by dropping conditions or changing technical meaning.

Distinguish when useful among:

- what the teacher literally established;
- how the user interpreted it;
- the correction or missing condition;
- an additional connection that goes beyond the lecture.

For pasted teacher transcripts, first recover the intended argument faithfully. Add extensions only after the original argument is clear.

Use concrete shapes, small numbers, and named examples for beginner-facing mathematical explanations. Check dimensions before explaining matrix operations. Do not call arbitrary model scores “probabilities” unless the model applies an operation such as softmax that makes them a valid distribution.

When writing formulas into an Obsidian note, use `$...$` for inline math and `$$...$$` for display math. Keep operators inside the math delimiters and check for stray characters introduced by transcription or formatting.

## Generate and Preserve Visuals

Associate every generated image with the exact visual teaching unit it explains. Prefer descriptive filenames when the image is saved, for example:

`YYYY-MM-DD-topic-concept.png`

When a target SecondBrain note or resource directory is already known, save the reviewed image in the matching year resource directory. Otherwise retain the generated artifact path and archive it during final-note creation.

In the final note:

- place the lecture overview image immediately after the summary heading;
- place each focused image immediately beside the subsection or explanation it supports;
- reuse correct images generated during the live discussion;
- create an additional overview image if the existing section images do not explain the complete lecture structure;
- verify every embedded file exists and renders.

Do not collect all diagrams at the bottom of the note. An image buried only in the transcript does not satisfy the corresponding summary section's visual requirement.

## Write the Final Classroom Note

Write or update the final note only after an explicit request such as “可以写笔记了” or “把这堂课整理成日记”. Until then, continue the live learning conversation.

Follow the loaded SecondBrain and Obsidian skills. By default, produce two separate, bidirectionally linked notes rather than mixing the transcript into the primary note:

1. **Structured classroom note**: the durable primary note organized by the lecture's conceptual sequence.
2. **Cleaned full-transcript resource**: a secondary note preserving every visible user question and assistant answer in chronological order.

Use sibling filenames such as `YYYY-MM-DD-topic.md` and `YYYY-MM-DD-topic-transcript.md`. Link the transcript near the beginning of the structured note, and link back to the structured note near the beginning of the transcript.

### Structured classroom note

Use this default shape unless the surrounding vault has a stronger convention:

1. frontmatter and one H1;
2. a one-paragraph or callout summary;
3. the lecture overview image;
4. the lecture's position, question, or learning goals;
5. numbered mainline sections in teaching order;
6. sideways questions nested under the section they clarify, preferably as short question callouts;
7. code, worked examples, limitations, and transitions where they belong;
8. a compact review or key-question table;
9. related-note links and external sources.

Keep the structured note self-contained. Do not paste the raw chat into its body. Do not add internal QA prose such as formula-validation results to the note itself.

### Cleaned full-transcript resource

Preserve every visible in-scope user message and assistant answer, including formulas, code, links, corrections, and consecutive user follow-ups. Clean only presentation metadata that is not part of the conversation:

- remove `Files mentioned by the user`, `My request for Codex`, attachment IDs, temporary filesystem paths, response-annotation wrappers, and skill invocation links;
- preserve quoted context selected by a response annotation as a readable quote when it is needed to understand the follow-up;
- never turn attachment names or temporary paths into headings;
- embed a real vault image when an attachment is genuinely needed and has been archived; otherwise omit the attachment wrapper rather than printing its path;
- organize turns under simple chronological headings such as `对话 01`, with `用户` and `AI` labels;
- demote headings inside individual replies so they do not pollute the resource note's top-level structure;
- do not summarize, rewrite, or silently drop substantive conversational content.

Then apply these lecture-specific rules to both outputs:

1. Identify the precise lecture boundary in the conversation.
2. Create the cleaned transcript resource before finalizing the structured note, so the original exchange can never be lost during restructuring.
3. Build the structured note in mainline order rather than chat order alone.
4. Nest sideways questions under the mainline section they clarify, or collect genuinely cross-cutting questions in a short “横向追问” section.
5. Preserve exact formulas, dimensions, code, teacher examples, user misunderstandings, and final corrections.
6. Embed the reviewed images beside the corresponding concepts.
7. Add sources and related-note links where useful without replacing the self-contained explanation.
8. Build an internal coverage checklist mapping every substantive user question to a section in the structured note. Add or expand a section when a key question is missing; leave minor repetitions only in the transcript resource.
9. Validate frontmatter, Obsidian math, code fences, wikilinks, image embeds, resource paths, chronological transcript completeness, and the bidirectional note links.

Handle homework conservatively:

- include only homework explicitly assigned with this lecture or substantially covered by its taught material;
- include the original question, a plain-language explanation, the complete final answer or code, the reasoning, the course knowledge used, and source links when solutions are requested;
- omit the homework section when this lecture has no matching assignment;
- never fill the gap with the next unrecorded homework;
- defer a later homework to the first lecture that actually covers it.

Report the note path and the main validation performed after saving.

## Common Failure Modes

Avoid these mistakes:

- treating every user question as the next point in the lecture;
- agreeing with an interpretation without checking it;
- overcompressing a transcript until caveats and reasoning disappear;
- answering a mainline chunk without creating a new explanatory image;
- defaulting to exactly one image regardless of the number of independent visual teaching units;
- putting several unrelated mechanisms into one large omnibus infographic;
- filling images with paragraph-length text that belongs in the prose;
- generating a decorative image that does not encode the explanation;
- relying on an image containing malformed formulas or labels;
- calling logits, similarities, or raw inner products probabilities;
- separating a diagram from the section it explains;
- placing raw attachment metadata, temporary paths, or chat-export headings in either note;
- using the full transcript as the primary note and thereby destroying the lecture's conceptual structure;
- overwriting or deleting the only complete transcript while restructuring the primary note;
- claiming that key questions were covered without checking them against the transcript;
- writing the final note before the user asks;
- attaching homework to the wrong lecture.

## Compact Response Patterns

For a mainline chunk, use this conceptual order without mechanically repeating the labels:

1. conclusion and assessment of the user's understanding;
2. teacher's reasoning in plain language;
3. exact technical details and a small example;
4. the planned set of newly generated focused images, placed beside the concepts they explain;
5. connection to the lecture mainline.

For a sideways question, use this conceptual order:

1. direct answer;
2. example or counterexample;
3. connection back to the current mainline;
4. whether the mainline conclusion changes.
