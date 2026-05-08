#!/bin/bash
set -euo pipefail

# parses syslog and X.log to extract INFO, Warning, and Information messages

if [[ $# -lt 2 ]]; then
    echo "usage: $0 <syslog_file> <xorg_log_file>"
    exit 1
fi

SYSLOG_FILE="$1"
XORG_FILE="$2"

OUT_INFO="info.log"
OUT_FULL="full.log"

awk '$2 == "INFO"' "$SYSLOG_FILE" > "$OUT_INFO"

sed -n -e 's/(WW)/Warning:/p' -e 's/(II)/Information:/p' "$XORG_FILE" > "$OUT_FULL"