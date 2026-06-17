#!/usr/bin/env python3
"""Fetch a WeChat public account article to Markdown with local image assets."""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/131.0.0.0 Safari/537.36"
)

IMAGE_MD_RE = re.compile(r"!\[([^\]]*)\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
IMAGE_HTML_RE = re.compile(
    r"<img\b[^>]*(?:src|data-src)=[\"']([^\"']+)[\"'][^>]*>",
    re.IGNORECASE,
)

STOP_LINES = {
    "继续滑动看下一个",
    "向上滑动看下一个",
    "微信扫一扫",
    "使用小程序",
}

DROP_LINES = {
    "在小说阅读器读本章",
    "去阅读",
}

BAD_FETCH_MARKERS = {
    "Warning: This page maybe requiring CAPTCHA",
    "Weixin Official Accounts Platform",
    "环境异常",
    "完成验证后即可继续访问",
}


def log(message: str, quiet: bool = False) -> None:
    if not quiet:
        print(message, file=sys.stderr)


def http_get_bytes(
    url: str,
    *,
    headers: Optional[Dict[str, str]] = None,
    timeout: int = 30,
) -> Tuple[bytes, str]:
    req_headers = {"User-Agent": UA}
    if headers:
        req_headers.update(headers)
    req = urllib.request.Request(url, headers=req_headers)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        content_type = resp.headers.get("Content-Type", "")
        return resp.read(), content_type


def http_get_text(
    url: str,
    *,
    headers: Optional[Dict[str, str]] = None,
    timeout: int = 30,
) -> str:
    data, content_type = http_get_bytes(url, headers=headers, timeout=timeout)
    charset = "utf-8"
    match = re.search(r"charset=([^;\s]+)", content_type, re.IGNORECASE)
    if match:
        charset = match.group(1)
    return data.decode(charset, errors="replace")


def http_get_json(url: str, *, timeout: int = 30) -> object:
    return json.loads(http_get_text(url, timeout=timeout))


def unwrap_wechat_url(url: str) -> str:
    parsed = urllib.parse.urlparse(url)
    if "wappoc_appmsgcaptcha" not in parsed.path:
        return url
    params = urllib.parse.parse_qs(parsed.query)
    target = params.get("target_url", [""])[0]
    return target or url


def output_path_for_url(url: str) -> Path:
    parsed = urllib.parse.urlparse(url)
    token = parsed.path.rstrip("/").split("/")[-1] or "article"
    token = re.sub(r"[^A-Za-z0-9._-]+", "_", token).strip("._-") or "article"
    return Path(f"wechat_{token}.md")


def fetch_markdown(
    url: str,
    *,
    timeout: int,
    wechat_api: str,
    quiet: bool,
) -> str:
    errors: List[str] = []

    if wechat_api:
        endpoint = (
            wechat_api.rstrip("/")
            + "/api/article?url="
            + urllib.parse.quote(url, safe="")
        )
        try:
            log(f"[wechat/exporter] {endpoint}", quiet)
            data = http_get_json(endpoint, timeout=timeout)
            if isinstance(data, dict):
                content = (
                    data.get("markdown")
                    or data.get("content")
                    or data.get("html")
                    or json.dumps(data, ensure_ascii=False, indent=2)
                )
            else:
                content = json.dumps(data, ensure_ascii=False, indent=2)
            log(f"[wechat/exporter] ok ({len(str(content))} chars)", quiet)
            content = str(content)
            if is_bad_fetch(content):
                raise RuntimeError("backend returned WeChat verification/CAPTCHA page")
            return content
        except Exception as exc:
            errors.append(f"wechat-exporter: {exc}")
            log(f"[wechat/exporter] failed: {exc}", quiet)

    strategies = [
        ("Jina", f"https://r.jina.ai/{url}", {"Accept": "text/markdown"}),
        ("defuddle", f"https://defuddle.md/{url}", None),
        ("raw", url, None),
    ]
    for name, fetch_url, headers in strategies:
        try:
            log(f"[wechat/{name}] fetching...", quiet)
            content = http_get_text(fetch_url, headers=headers, timeout=timeout)
            log(f"[wechat/{name}] ok ({len(content)} chars)", quiet)
            if is_bad_fetch(content):
                raise RuntimeError("backend returned WeChat verification/CAPTCHA page")
            return content
        except Exception as exc:
            errors.append(f"{name}: {exc}")
            log(f"[wechat/{name}] failed: {exc}", quiet)

    raise RuntimeError("All WeChat fetch strategies failed:\n  " + "\n  ".join(errors))


def is_bad_fetch(markdown: str) -> bool:
    return any(marker in markdown for marker in BAD_FETCH_MARKERS)


def frontmatter_value(markdown: str, key: str) -> Optional[str]:
    if not markdown.startswith("---\n"):
        return None
    end = markdown.find("\n---", 4)
    if end == -1:
        return None
    block = markdown[4:end]
    pattern = rf"^{re.escape(key)}:\s*[\"']?(.+?)[\"']?\s*$"
    match = re.search(pattern, block, re.MULTILINE)
    if not match:
        return None
    return match.group(1).strip().strip('"').strip("'") or None


def frontmatter_title(markdown: str) -> Optional[str]:
    return frontmatter_value(markdown, "title")


def has_visible_h1(markdown: str) -> bool:
    body = markdown
    if markdown.startswith("---\n"):
        end = markdown.find("\n---", 4)
        if end != -1:
            body = markdown[end + 4 :]
    return bool(re.search(r"(?m)^#\s+\S", body[:1000]))


def clean_wechat_ui(markdown: str) -> str:
    lines = markdown.splitlines()
    author = frontmatter_value(markdown, "author")
    repeated_author_prefix = ""
    if author:
        repeated_author_prefix = f"{author.lower()} {author.lower()}"

    cleaned: List[str] = []
    for index, line in enumerate(lines):
        stripped = line.strip()
        if stripped in DROP_LINES:
            continue
        if (
            repeated_author_prefix
            and index < 30
            and stripped.lower().startswith(repeated_author_prefix)
        ):
            continue
        cleaned.append(line)
    lines = cleaned

    stop_index: Optional[int] = None
    for index, line in enumerate(lines):
        if line.strip() in STOP_LINES:
            stop_index = index
            break
    if stop_index is not None:
        lines = lines[:stop_index]

    for index in range(max(0, len(lines) - 40), len(lines)):
        if lines[index].strip() != "END":
            continue
        tail = "\n".join(lines[index + 1 :])
        if "![](" in tail or any(marker in tail for marker in STOP_LINES):
            lines = lines[:index]
            break

    compacted: List[str] = []
    blank_count = 0
    for line in lines:
        if line.strip():
            blank_count = 0
            compacted.append(line)
        else:
            blank_count += 1
            if blank_count <= 2:
                compacted.append(line)

    markdown = "\n".join(compacted).strip() + "\n"
    title = frontmatter_title(markdown)
    if title and not has_visible_h1(markdown):
        if markdown.startswith("---\n"):
            end = markdown.find("\n---", 4)
            if end != -1:
                insert = end + 4
                markdown = markdown[:insert].rstrip() + f"\n\n# {title}\n" + markdown[insert:]
        else:
            markdown = f"# {title}\n\n{markdown}"
    return markdown


def is_remote_url(url: str) -> bool:
    parsed = urllib.parse.urlparse(url)
    return parsed.scheme in {"http", "https"}


def image_extension(url: str, content_type: str = "") -> str:
    parsed = urllib.parse.urlparse(url)
    query = urllib.parse.parse_qs(parsed.query)
    wx_fmt = (query.get("wx_fmt") or [""])[0].lower()
    if wx_fmt in {"jpeg", "jpg"}:
        return ".jpg"
    if wx_fmt in {"png", "gif", "webp", "bmp"}:
        return "." + wx_fmt

    content_type = content_type.lower()
    if "jpeg" in content_type:
        return ".jpg"
    for ext in ("png", "gif", "webp", "bmp"):
        if ext in content_type:
            return "." + ext

    suffix = Path(parsed.path).suffix.lower()
    if suffix in {".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp"}:
        return ".jpg" if suffix == ".jpeg" else suffix
    return ".png"


def collect_image_urls(markdown: str) -> List[str]:
    urls: List[str] = []
    seen = set()
    for match in IMAGE_MD_RE.finditer(markdown):
        url = html.unescape(match.group(2))
        if is_remote_url(url) and url not in seen:
            seen.add(url)
            urls.append(url)
    for match in IMAGE_HTML_RE.finditer(markdown):
        url = html.unescape(match.group(1))
        if is_remote_url(url) and url not in seen:
            seen.add(url)
            urls.append(url)
    return urls


def relative_path(from_file: Path, target: Path) -> str:
    rel = os.path.relpath(target, start=from_file.parent)
    return Path(rel).as_posix()


def download_images(
    markdown: str,
    *,
    article_url: str,
    output_file: Path,
    assets_dir: Path,
    timeout: int,
    best_effort: bool,
    quiet: bool,
) -> Tuple[str, int]:
    urls = collect_image_urls(markdown)
    if not urls:
        return markdown, 0

    assets_dir.mkdir(parents=True, exist_ok=True)
    replacements: Dict[str, str] = {}

    for index, url in enumerate(urls, start=1):
        try:
            data, content_type = http_get_bytes(
                url,
                headers={"Referer": article_url},
                timeout=timeout,
            )
            ext = image_extension(url, content_type)
            path = assets_dir / f"image{index:02d}{ext}"
            path.write_bytes(data)
            replacements[url] = relative_path(output_file, path)
            log(f"[image] {index:02d} -> {path} ({len(data)} bytes)", quiet)
        except Exception as exc:
            message = f"Failed to download image {index:02d}: {url}\n{exc}"
            if best_effort:
                log(f"[image] {message}", quiet)
                continue
            raise RuntimeError(message) from exc

    def replace_md(match: re.Match[str]) -> str:
        alt = match.group(1)
        url = html.unescape(match.group(2))
        local = replacements.get(url)
        if not local:
            return match.group(0)
        return f"![{alt}]({local})"

    markdown = IMAGE_MD_RE.sub(replace_md, markdown)

    def replace_html(match: re.Match[str]) -> str:
        url = html.unescape(match.group(1))
        local = replacements.get(url)
        if not local:
            return match.group(0)
        return f"![]({local})"

    markdown = IMAGE_HTML_RE.sub(replace_html, markdown)
    return markdown, len(replacements)


def remote_image_links(markdown: str) -> List[str]:
    return collect_image_urls(markdown)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Fetch a WeChat article to Markdown with local image assets."
    )
    parser.add_argument("url", help="WeChat article URL")
    parser.add_argument("-o", "--output", help="Markdown output path")
    parser.add_argument("--assets-dir", help="Directory for downloaded image assets")
    parser.add_argument("--wechat-api", default=os.environ.get("WECHAT_API_URL", ""))
    parser.add_argument("--timeout", type=int, default=30)
    parser.add_argument("--no-images", action="store_true", help="Do not download images")
    parser.add_argument(
        "--best-effort-images",
        action="store_true",
        help="Keep remote image links when a download fails",
    )
    parser.add_argument("--no-clean", action="store_true", help="Skip WeChat UI cleanup")
    parser.add_argument("-q", "--quiet", action="store_true")
    return parser


def main(argv: Optional[Iterable[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    url = unwrap_wechat_url(args.url)
    output_file = Path(args.output) if args.output else output_path_for_url(url)
    output_file = output_file.expanduser()
    assets_dir = (
        Path(args.assets_dir).expanduser()
        if args.assets_dir
        else output_file.with_name(output_file.stem + "_assets")
    )

    markdown = fetch_markdown(
        url,
        timeout=args.timeout,
        wechat_api=args.wechat_api,
        quiet=args.quiet,
    )
    if not args.no_clean:
        markdown = clean_wechat_ui(markdown)

    image_count = 0
    if not args.no_images:
        markdown, image_count = download_images(
            markdown,
            article_url=url,
            output_file=output_file,
            assets_dir=assets_dir,
            timeout=args.timeout,
            best_effort=args.best_effort_images,
            quiet=args.quiet,
        )

    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(markdown, encoding="utf-8")

    remaining = remote_image_links(markdown)
    log(f"Saved Markdown: {output_file}", args.quiet)
    if not args.no_images:
        log(f"Saved assets: {assets_dir} ({image_count} images)", args.quiet)
    log(f"Remote image links remaining: {len(remaining)}", args.quiet)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
