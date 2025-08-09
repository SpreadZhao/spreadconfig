#!/usr/bin/env python
import subprocess

# function to parse output of command "wpctl status" and return a list of sources with their id and name.
def parse_wpctl_sources():
    output = str(subprocess.check_output("wpctl status", shell=True, encoding='utf-8'))

    lines = output.replace("├", "").replace("─", "").replace("│", "").replace("└", "").splitlines()

    sources_index = None
    for index, line in enumerate(lines):
        if "Sources:" in line:
            sources_index = index
            break

    sources = []
    for line in lines[sources_index + 1:]:
        if not line.strip():
            break
        sources.append(line.strip())

    for index, source in enumerate(sources):
        sources[index] = source.split("[vol:")[0].strip()

    for index, source in enumerate(sources):
        if source.startswith("*"):
            sources[index] = source.strip().replace("*", "").strip() + " - Default"

    sources_dict = [{"source_id": int(src.split(".")[0]), "source_name": src.split(".")[1].strip()} for src in sources]

    return sources_dict

# Get the list of sources formatted for wofi
output = ''
sources = parse_wpctl_sources()
for src in sources:
    if src['source_name'].endswith(" - Default"):
        output += f"<b>-> {src['source_id']}: {src['source_name']}</b>\n"
    else:
        output += f" {src['source_id']}: {src['source_name']}\n"

# Show wofi menu and get selection
wofi_command = f"echo '{output}' | wofi --show=dmenu --hide-scroll --allow-markup --define=prompt=\"Select Source\" --location=top_right --height=200 --xoffset=-60"
wofi_process = subprocess.run(wofi_command, shell=True, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if wofi_process.returncode != 0:
    # print("User cancelled the operation.")
    exit(0)

selected_source_name = wofi_process.stdout.strip()
selected_source_id = int(selected_source_name.strip('<b>').strip('</b>').split(":")[0].replace("->", "").strip())
sources = parse_wpctl_sources()
selected_source = next(src for src in sources if src['source_id'] == selected_source_id)
subprocess.run(f"wpctl set-default {selected_source['source_id']}", shell=True)
