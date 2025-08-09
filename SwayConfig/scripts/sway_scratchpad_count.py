#!/usr/bin/python
import json
import subprocess
import os

STATE_FILE = "/tmp/sway_scratchpad_index.txt"

def get_scratchpads():
    result = subprocess.run(["swaymsg", "-t", "get_tree"], stdout=subprocess.PIPE)
    data = json.loads(result.stdout.decode())

    scratchpads = []
    for output in data.get("nodes", []):
        for workspace in output.get("nodes", []):
            for node in workspace.get("floating_nodes", []):
                # Only consider scratchpads that are not visible (hidden)
                if node.get("visible") is False:
                    title = node.get("name") or node.get("title") or "Untitled"
                    app_id = node.get("app_id")
                    if app_id:
                        full_title = f"{title} [{app_id}]"
                    else:
                        full_title = title
                    scratchpads.append(full_title)
    return scratchpads

def read_index():
    try:
        # Read the last shown index from the state file
        with open(STATE_FILE, "r") as f:
            idx = int(f.read())
            return idx
    except Exception:
        # If file doesn't exist or invalid content, start from 0
        return 0

def write_index(idx):
    # Write the updated index back to the state file
    with open(STATE_FILE, "w") as f:
        f.write(str(idx))

def main():
    scratchpads = get_scratchpads()
    total = len(scratchpads)

    if total == 0:
        # If no scratchpads, remove state file to reset index next time
        try:
            os.remove(STATE_FILE)
        except FileNotFoundError:
            pass
        return

    idx = read_index()
    # Ensure index is within bounds in case scratchpad count changed
    idx = idx % total
    current_title = scratchpads[idx]

    # Print the icon, total count, current index, and current scratchpad title
    print(f"󱂬 {total} | {idx + 1}/{total}: {current_title}")

    # Update the index for next run, wrapping around with modulo
    idx = (idx + 1) % total
    write_index(idx)

if __name__ == "__main__":
    main()
