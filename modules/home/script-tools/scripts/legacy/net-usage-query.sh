#!/usr/bin/env bash

LOG_DIR="/home/spreadzhao/.local/share/net-log"

if [ -z "$1" ]; then
    echo "Usage:"
    echo "  net-usage-query list"
    echo "  net-usage-query <logfile>"
    exit 1
fi

if [ "$1" = "list" ]; then
    ls -lh "$LOG_DIR"
    exit 0
fi

LOG_FILE="$LOG_DIR/$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "File not found: $LOG_FILE"
    exit 1
fi

awk '
function human(x) {
    if (x > 1024*1024*1024)
        return sprintf("%.2f GB", x/1024/1024/1024)
    else if (x > 1024*1024)
        return sprintf("%.2f MB", x/1024/1024)
    else if (x > 1024)
        return sprintf("%.2f KB", x/1024)
    else
        return sprintf("%.2f B", x)
}

function escape(str) {
    gsub(/\\/,"\\\\",str)
    gsub(/"/,"\\\"",str)
    return str
}

NF==3 && $2 ~ /^[0-9.]+$/ {
    proc=$1
    up[proc]+=$2*1024
    down[proc]+=$3*1024
}

END {
    printf "{\n"
    printf "  \"processes\": [\n"

    first=1
    for (p in up) {
        if (!first)
            printf ",\n"
        first=0

        ep = escape(p)

        printf "    {\n"
        printf "      \"process\": \"%s\",\n", ep
        printf "      \"upload_bytes\": %.0f,\n", up[p]
        printf "      \"download_bytes\": %.0f,\n", down[p]
        printf "      \"upload_human\": \"%s\",\n", human(up[p])
        printf "      \"download_human\": \"%s\"\n", human(down[p])
        printf "    }"
    }

    printf "\n  ]\n"
    printf "}\n"
}
' "$LOG_FILE"
