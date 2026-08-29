#!/usr/bin/env python3

import argparse
import io
import json
import os
from pathlib import Path
import tempfile


def parse_quickmarks(source: Path) -> dict[str, list[dict[str, object]]]:
    bookmarks: list[dict[str, object]] = []
    folder_children: dict[tuple[str, ...], list[dict[str, object]]] = {}

    descriptor = os.open(source, os.O_RDONLY | os.O_NOFOLLOW)
    try:
        os.fchmod(descriptor, 0o600)
    except BaseException:
        os.close(descriptor)
        raise

    with io.open(descriptor, encoding="utf-8") as quickmarks:
        for line_number, raw_line in enumerate(quickmarks, start=1):
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue

            fields = line.rsplit(maxsplit=1)
            if len(fields) != 2:
                raise ValueError(
                    f"invalid quickmark at line {line_number}: expected a name and URL"
                )

            name, url = fields
            path = name.split("/")
            if any(not component for component in path):
                raise ValueError(
                    f"invalid quickmark at line {line_number}: empty path component"
                )

            children = bookmarks
            folder_path: tuple[str, ...] = ()
            for folder_name in path[:-1]:
                folder_path += (folder_name,)
                if folder_path not in folder_children:
                    nested_children: list[dict[str, object]] = []
                    children.append({"name": folder_name, "children": nested_children})
                    folder_children[folder_path] = nested_children
                children = folder_children[folder_path]

            children.append({"name": path[-1], "url": url})

    return {"ManagedBookmarks": bookmarks}


def write_policy(policy: dict[str, object], output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    file_descriptor, temporary_name = tempfile.mkstemp(
        dir=output.parent,
        prefix=f".{output.name}.",
    )
    temporary = Path(temporary_name)

    try:
        with os.fdopen(file_descriptor, "w", encoding="utf-8") as policy_file:
            json.dump(policy, policy_file, ensure_ascii=False, indent=2)
            policy_file.write("\n")
            policy_file.flush()
            os.fsync(policy_file.fileno())

        temporary.chmod(0o644)
        temporary.replace(output)
    except BaseException:
        temporary.unlink(missing_ok=True)
        raise


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Synchronize qutebrowser quickmarks to Chromium managed bookmarks"
    )
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    arguments = parser.parse_args()

    policy = parse_quickmarks(arguments.source)
    write_policy(policy, arguments.output)


if __name__ == "__main__":
    main()
