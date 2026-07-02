---
name: paper-reader
description: Create rigorous paper reading artifacts from PDFs, arXiv links, DOI pages, HTML, Markdown, or extracted text, including an opening summary and credibility assessment, a standalone key-question analysis, complete original text with Chinese parallel translation when legally available, and inline section summaries. Use when the user asks to read, translate, summarize, study, review, archive, or turn an academic paper into bilingual notes.
---

# Paper Reader

## Overview

Use this skill to turn an academic paper into a study artifact that preserves the paper, translates it, and explains how the work thinks. The default output language is Chinese, while paper titles, terms, formulas, identifiers, and cited names should retain their original forms where useful.

## Source Handling

Prefer user-provided local PDFs, text files, Markdown, HTML exports, or pasted paper text. If the user provides only a URL, DOI, arXiv ID, or title, fetch authoritative metadata and the paper from the publisher, arXiv, OpenReview, ACL Anthology, PubMed, ACM, IEEE, or the authors' official page when available.

Respect copyright and source permissions. Include the full original text only when the user supplied the document/text, the source is public domain or permissively licensed, or the user has an authorized copy for this transformation. If full reproduction is not allowed, explain that the requested complete bilingual artifact cannot be finished yet, provide citation metadata and high-level notes, and ask for an authorized local copy or text extraction.

For scanned PDFs or weak extraction, state the extraction method and uncertainty. Preserve section order, headings, equations, algorithms, table/figure captions, appendices, and references as far as the source allows. Do not silently omit sections; record missing or unreadable parts in a coverage checklist.

## Required Output Shape

Start every artifact with these sections:

1. `# 论文速览`
2. `## 摘要`
3. `## 可信度评估`
4. `## 关键问题与论文解法`
5. `## 全文原文与对照翻译`

After those required sections, add `## 总结与可复用模式`, `## 局限与阅读提醒`, or source/metadata sections when useful.

## Opening Summary

In `摘要`, cover:

- The paper's main task, core idea, method, and primary result.
- The specific research gap or practical problem it addresses.
- What a reader should remember after five minutes.
- One short note on whether the paper is mainly theoretical, empirical, systems-oriented, benchmark-oriented, or survey-like.

Keep this section short enough to scan before the full translation.

## Credibility Assessment

In `可信度评估`, distinguish between authority signals and actual evidential strength. Check current information when the user asks for authority, recognition, citation status, recent influence, or whether the paper is widely accepted.

Assess at least:

- Venue and review status: peer-reviewed venue, workshop/preprint, publisher, year, DOI/arXiv/OpenReview identifiers.
- Authors and institutions: relevant track record when it is knowable and useful.
- Recognition: citation count, well-known follow-up work, benchmark adoption, replication, open-source implementation, or standard references.
- Evidence quality: dataset scale, baselines, ablations, statistical rigor, proofs, reproducibility, and whether claims exceed evidence.
- Conflicts and limits: funding, author incentives, missing experiments, dataset leakage risks, unrealistic assumptions, or narrow domains.

End with a calibrated label: `高可信`, `中等可信`, `低可信`, or `可信度未明`. Explain whether the paper is worth referencing and for what purpose.

## Key Questions Section

`关键问题与论文解法` is an independent section, not a loose summary. Select 4-8 questions that reveal the paper's intellectual structure.

For each question, use this format:

```markdown
### Q1. <关键问题>

- 为什么关键：
- 论文怎么解决：
- 证据在哪里：
- 仍然不足：
```

Prefer questions about the research gap, formulation, assumptions, mechanism, data/evaluation, comparison to prior work, surprising result, limitation, and real-world applicability. Tie every answer back to specific sections, equations, figures, tables, or experiments from the paper.

## Full Original and Parallel Translation

`全文原文与对照翻译` must preserve the whole paper when permitted. Use stable chunking by section and paragraph so a reader can map translation back to source text.

Use this pattern:

```markdown
### <section number/title>

**原文**

> <original paragraph or coherent block>

**译文**

<Chinese translation>
```

Translate faithfully before explaining. Preserve technical terms on first mention with `中文译名（English term）` when helpful, then use the shorter Chinese form consistently. Keep equations, symbols, citations, table numbers, figure numbers, algorithm names, and variable names aligned with the original. Do not invent missing claims or "smooth over" uncertainty.

For references and bibliographic entries, preserve the original entries. Add Chinese notes only when a cited work is central to understanding the paper.

## Inline Summaries

Insert concise summaries at natural breakpoints, usually after Abstract, Introduction, Method, Experiments/Results, Discussion, and Conclusion. Use `> 小结：...` blocks so summaries do not interrupt the original/translation alignment.

Each summary should answer:

- What did this part establish?
- What changed in the reader's understanding?
- What should be checked against later evidence?

Avoid summarizing every paragraph; use summaries where they reduce cognitive load.

## Quality Checks

Before finishing, verify:

- The opening summary and credibility assessment are at the top.
- The key-question section is separate and uses explicit Q/A structure.
- The full original text and Chinese translation are both present, unless a rights or extraction limitation was explicitly reported.
- Section order matches the paper.
- All skipped, unreadable, or legally restricted parts are listed.
- Claims about recognition, citation count, venue, or "widely accepted" status are sourced or clearly marked as unverified.
