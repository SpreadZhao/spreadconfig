---
name: wechat-article-fetcher
description: Fetch WeChat public account articles from mp.weixin.qq.com into clean Markdown with local image assets. Use when the user asks to grab, archive, crawl, save, export, or convert a WeChat/微信公众号 article, especially when they want images downloaded locally, Markdown image links rewritten to an assets folder, or an offline copy of a WeChat article.
---

# WeChat Article Fetcher

## Overview

Use this skill to turn a WeChat public account article URL into a local Markdown file plus a sibling assets directory containing downloaded article images.

Prefer the bundled script instead of hand-copying image URLs. It uses the existing fetch-skill backend order for WeChat content, then adds deterministic local asset handling.

## Quick Start

Run:

```bash
python3 /home/spreadzhao/.codex/skills/wechat-article-fetcher/scripts/fetch_wechat_article.py "https://mp.weixin.qq.com/s/..." -o article.md
```

If `python3` is not on PATH in this environment, run through Nix:

```bash
nix shell nixpkgs#python3 --command python3 /home/spreadzhao/.codex/skills/wechat-article-fetcher/scripts/fetch_wechat_article.py "https://mp.weixin.qq.com/s/..." -o article.md
```

The default output layout is:

```text
article.md
article_assets/
  image01.png
  image02.jpg
```

## Workflow

1. Choose an output filename. For article IDs, prefer `wechat_<id>.md`.
2. Run the script with the URL and output path.
3. If the first run fails due to network sandboxing, rerun the same command with escalation approval.
4. Inspect the top and tail of the Markdown for WeChat UI noise.
5. Verify that no remote image CDN URLs remain:

```bash
rg -n "mmbiz\.qpic\.cn|!\[[^]]*\]\(https?://" article.md
find article_assets -type f | sort
```

## Script Behavior

The script:

- unwraps common WeChat captcha redirect URLs via `target_url`;
- fetches content through `WECHAT_API_URL` or `--wechat-api` when configured, then Jina Reader, then defuddle.md, then raw HTML;
- removes common trailing WeChat UI text such as slide prompts and mini-program controls;
- adds an H1 title from frontmatter when the backend produced metadata but no visible title;
- downloads Markdown and HTML image URLs into the assets directory;
- rewrites Markdown image references to relative local paths;
- fails on image download errors by default so offline archives do not silently keep broken remote links.

Use `--best-effort-images` only when a partial archive is acceptable. Use `--no-images` only when the user explicitly does not need local images.

## Options

Common options:

```bash
python3 scripts/fetch_wechat_article.py URL \
  -o output.md \
  --assets-dir output_assets \
  --wechat-api http://localhost:3000 \
  --timeout 30 \
  --best-effort-images
```

Environment:

- `WECHAT_API_URL`: optional wechat-article-exporter base URL, for example `http://localhost:3000`.

## Quality Bar

Before finishing, report:

- Markdown file path.
- Assets directory path.
- Number of downloaded images.
- Whether remote image links remain.

If a backend returns noisy Markdown, clean only obvious WeChat page chrome. Do not paraphrase or rewrite article content unless the user asks for a summary or rewrite.
