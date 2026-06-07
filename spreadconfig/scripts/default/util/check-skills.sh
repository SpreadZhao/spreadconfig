#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 0 ]; then
    roots=("$@")
else
    roots=(
        "$HOME/.agents/skills"
        "$HOME/.codex/skills"
        "/etc/codex/skills"
        ".agents/skills"
    )
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

for root in "${roots[@]}"; do
    [ -d "$root" ] || continue

    find "$root" -mindepth 2 -maxdepth 2 -name SKILL.md -print | sort | while IFS= read -r skill_file; do
        dir="$(dirname "$skill_file")"
        name="$(
            awk -F ': *' '/^name:/ { print $2; exit }' "$skill_file" |
                sed 's/^["'\'']\|["'\'']$//g'
        )"
        description="$(
            awk -F ': *' '/^description:/ { print $2; exit }' "$skill_file" |
                sed 's/^["'\'']\|["'\'']$//g'
        )"

        if [ -z "$name" ]; then
            printf 'missing name: %s\n' "$skill_file"
        fi

        if [ -z "$description" ]; then
            printf 'missing description: %s\n' "$skill_file"
        fi

        printf '%s\t%s\t%s\n' "$name" "$dir" "$description" >> "$tmp"
        printf '%s -> name=%s description=%s\n' "$dir" "${name:-<missing>}" "${description:-<missing>}"
    done
done

duplicates="$(
    awk -F '\t' '$1 != "" { count[$1]++ } END { for (name in count) if (count[name] > 1) print name }' "$tmp"
)"

if [ -n "$duplicates" ]; then
    printf '\nduplicate skill names:\n'
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        printf '- %s\n' "$name"
        awk -F '\t' -v name="$name" '$1 == name { printf "  %s\n", $2 }' "$tmp"
    done <<< "$duplicates"
    exit 1
fi
