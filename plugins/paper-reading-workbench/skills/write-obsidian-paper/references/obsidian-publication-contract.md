# Obsidian Publication Contract

## Main Bilingual Rhythm

Use source text as a blockquote followed immediately by natural Chinese:

```markdown
### Contrastive objective · 对比学习目标

> The model learns by distinguishing positive pairs from in-batch negatives. ^P12AB34CD-S000042

模型通过区分正样本对与同一批次中的负样本来学习。
```

Do not label either block. Keep several short original paragraphs separate rather than creating an unreadable wall of quotation.

## Figures, Tables, and Formulas

Use relative Markdown embeds so the complete paper folder remains movable:

```markdown
![Figure 2 · 模型整体结构](../assets/figures/P12AB34CD-figure-02.png)
```

Keep the source caption and Chinese translation with the asset. Preserve display math as LaTeX without converting it to prose. Rebuild readable Markdown tables when reliable; otherwise embed a verified table image and retain an accessible textual transcription nearby.

## Footnote Placement

Use a paper-scoped question ID:

```markdown
这里的温度参数控制分布的尖锐程度。[^P12AB34CD-Q0007]

[^P12AB34CD-Q0007]: 温度越低，模型越强调最相似的候选项；这一解释来自论文公式（4）及补充实验。
```

## Collapsible Callout

Use a question callout when the explanation is useful in place but would interrupt the mainline:

```markdown
> [!question]- P12AB34CD-Q0012 · 为什么不直接使用所有负样本？
> 论文的直接理由是计算代价；更深一层还涉及错误负样本带来的偏差。
>
> **证据**　论文 §3.2、表 4；外部实现说明见 [[P12AB34CD-Q0012 · 负样本选择|完整研究笔记]]。
```

## Child Notes

Name child notes `<paper-id>-Q#### · <short-title>.md` or `<paper-id>-CONCEPT-#### · <title>.md`. Link with an alias so the visible sentence remains natural:

```markdown
这一步与互信息下界的关系较长，见 [[P12AB34CD-Q0018 · 互信息下界|推导与争议]]。
```

Keep the local summary sufficient for uninterrupted reading. The child note holds derivations, source comparison, long evidence chains, and related questions.

## Portability

- Never use an absolute local path or `file://` link.
- Use relative Markdown paths for folder-sensitive navigation and assets.
- Use paper-scoped unique filenames for wikilinks; add aliases for human-readable prose.
- Avoid CSS snippets, Dataview, Bases, Canvas, or community-plugin-only syntax in v1.
- Preserve standard Markdown readability outside Obsidian.

## Coverage

Every ledger question must appear as a footnote, callout, or child-note placement. A coverage record points to the exact target file and nearby heading or source anchor. Open research and unanswerable questions still require an honest placement when they affect interpretation.
