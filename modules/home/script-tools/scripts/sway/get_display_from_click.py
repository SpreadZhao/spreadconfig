#!/usr/bin/env python3
import os
import subprocess
import json
import sys

def get_display_from_click(x, y):
    try:
        output = subprocess.check_output(["swaymsg", "-t", "get_outputs"], encoding="utf-8")
        outputs = json.loads(output)

        for out in outputs:
            if not out.get("active"):
                continue
            rect = out.get("rect", {})
            ox, oy = rect["x"], rect["y"]
            ow, oh = rect["width"], rect["height"]

            if ox <= x < ox + ow and oy <= y < oy + oh:
                return out["name"]
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None

def main():
    try:
        x = int(os.environ.get("BLOCK_X", "0"))
        y = int(os.environ.get("BLOCK_Y", "0"))
    except Exception:
        print("Invalid coordinates", file=sys.stderr)
        sys.exit(1)

    display = get_display_from_click(x, y)
    if display:
        print(display)
    else:
        print("Unknown", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
