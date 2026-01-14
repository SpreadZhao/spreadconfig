#!/usr/bin/env python3
import subprocess
import sys

def parse_wpctl_section(section_name):
    """Parse wpctl status section (Sinks or Sources)"""
    output = subprocess.check_output("wpctl status", shell=True, encoding="utf-8")
    lines = output.replace("├", "").replace("─", "").replace("│", "").replace("└", "").splitlines()

    # Find section
    start_index = None
    for i, line in enumerate(lines):
        if f"{section_name}:" in line:
            start_index = i
            break
    if start_index is None:
        return []

    section = []
    for line in lines[start_index + 1:]:
        if not line.strip():
            break
        section.append(line.strip())

    # Cleanup and parse
    for i, item in enumerate(section):
        section[i] = item.split("[vol:")[0].strip()
        if item.startswith("*"):
            section[i] = section[i].replace("*", "").strip() + " - Default"

    return [
        {
            "id": int(item.split(".")[0]),
            "name": item.split(".")[1].strip()
        }
        for item in section
    ]

def select_with_wofi(prompt, entries):
    """Show wofi selection"""
    output = ''
    for e in entries:
        if e["name"].endswith(" - Default"):
            output += f"<b>-> {e['id']}: {e['name']}</b>\n"
        else:
            output += f" {e['id']}: {e['name']}\n"

    cmd = (
        f"echo '{output}' | "
        f"wofi --show=dmenu --hide-scroll --allow-markup "
        f"--define=prompt=\"{prompt}\""
    )
    res = subprocess.run(cmd, shell=True, encoding="utf-8", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if res.returncode != 0 or not res.stdout.strip():
        sys.exit(0)
    selected_line = res.stdout.strip()
    selected_id = int(selected_line.strip('<b>').strip('</b>').split(":")[0].replace("->", "").strip())
    return selected_id

def main():
    # Step 1: Ask whether to change Sink or Source
    choice_cmd = (
        "echo 'Sink (Output)\nSource (Input)' | "
        "wofi --show=dmenu --define=prompt='Choose Type'"
    )
    res = subprocess.run(choice_cmd, shell=True, encoding="utf-8", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if res.returncode != 0 or not res.stdout.strip():
        sys.exit(0)
    choice = res.stdout.strip().lower()

    if "sink" in choice:
        section = "Sinks"
        cmd_prefix = "wpctl set-default"
    elif "source" in choice:
        section = "Sources"
        cmd_prefix = "wpctl set-default"
    else:
        sys.exit(0)

    items = parse_wpctl_section(section)
    selected_id = select_with_wofi(f"Select {section[:-1]}", items)
    subprocess.run(f"{cmd_prefix} {selected_id}", shell=True)

if __name__ == "__main__":
    main()
