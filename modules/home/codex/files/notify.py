import html
import json
from pathlib import Path
import subprocess
import sys


def main():
    notifier, profile, payload = sys.argv[1:]
    event = json.loads(payload)
    if event.get("type") != "agent-turn-complete":
        return

    message = (event.get("last-assistant-message") or "").strip() or "Turn complete."
    if len(message) > 1000:
        message = message[:999] + "…"

    project = Path(event.get("cwd") or ".").name
    title = f"Codex · {profile}"
    if project:
        title += f" · {project}"

    subprocess.run(
        [
            notifier,
            "--app-name=Codex CLI",
            "--icon=codex-desktop",
            "--",
            title,
            html.escape(message, quote=False),
        ],
        check=True,
    )


if __name__ == "__main__":
    main()
