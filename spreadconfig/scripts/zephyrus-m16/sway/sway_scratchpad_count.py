#!/usr/bin/python
import json
import subprocess
import os
import re

# ===========================
# Configurations
# ===========================

STATE_FILE = "/tmp/sway_scratchpad_index.txt"
MAX_LEN = 30                 # Max length for NAME_PART
TRUNCATE_MODE = "head"       # Options: head | tail | both

# ===========================
# Helpers
# ===========================

def run_swaymsg_get_tree():
    """Run swaymsg to get the full tree JSON."""
    result = subprocess.run(["swaymsg", "-t", "get_tree"], stdout=subprocess.PIPE)
    return json.loads(result.stdout.decode())

def strip_after_last_dash(s):
    """
    Keep everything before the LAST dash (supports -, ‐, –, —).
    If no dash found, return string as is.
    """
    # Find the last dash of any type
    match = re.search(r"^(.*?)[\s]*[-‐–—][\s]*[^-‐–—]+$", s)
    return match.group(1) if match else s

def truncate_string(s):
    """
    Truncate string according to MAX_LEN and TRUNCATE_MODE.
    Modes:
        head: Keep start
        tail: Keep end
        both: Keep start + end, ellipsis in middle
    """
    if len(s) <= MAX_LEN:
        return s

    if TRUNCATE_MODE == "head":
        return s[:MAX_LEN] + "…"
    elif TRUNCATE_MODE == "tail":
        return "…" + s[-MAX_LEN:]
    elif TRUNCATE_MODE == "both":
        half = (MAX_LEN - 1) // 2
        return s[:half] + "…" + s[-half:]
    else:
        return s[:MAX_LEN] + "…"

def process_title_and_app_id(title, app_id):
    """
    Apply dash strip & truncation to title part only, keep app_id unchanged.
    """
    # Step 1: strip after last dash in the title part
    title_processed = strip_after_last_dash(title)

    # Step 2: truncate title part if needed
    title_processed = truncate_string(title_processed)

    # Step 3: return combined result
    return f"{title_processed} [{app_id}]" if app_id else title_processed

def get_scratchpads():
    """
    Return a list of hidden scratchpad windows as processed strings:
        "processed_title [app_id]" or just "processed_title"
    """
    data = run_swaymsg_get_tree()
    scratchpads = []

    for output in data.get("nodes", []):
        for workspace in output.get("nodes", []):
            for node in workspace.get("floating_nodes", []):
                if node.get("visible") is False:  # hidden scratchpads only
                    title = node.get("name") or node.get("title") or "Untitled"
                    app_id = node.get("app_id")
                    processed = process_title_and_app_id(title, app_id)
                    scratchpads.append(processed)
    return scratchpads

def read_index():
    """Read last shown index from state file, fallback to 0."""
    try:
        with open(STATE_FILE, "r") as f:
            return int(f.read())
    except Exception:
        return 0

def write_index(idx):
    """Write index to state file."""
    with open(STATE_FILE, "w") as f:
        f.write(str(idx))

# ===========================
# Main
# ===========================

def main():
    scratchpads = get_scratchpads()
    total = len(scratchpads)

    if total == 0:
        try:
            os.remove(STATE_FILE)
        except FileNotFoundError:
            pass
        return

    idx = read_index() % total
    current_title = scratchpads[idx]

    print(f"󱂬 {total} | {idx + 1}/{total}: {current_title}")

    write_index((idx + 1) % total)

if __name__ == "__main__":
    main()
