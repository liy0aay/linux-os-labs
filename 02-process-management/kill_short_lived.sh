#!/bin/bash
set -euo pipefail

# terminates processes that have been running for less than N seconds

if [[ $# -eq 0 ]]; then
    echo "usage: $0 <max_age_seconds> [log_file]"
    exit 1
fi

MAX_AGE="$1"
LOG_FILE="${2:-killed.log}"

> "$LOG_FILE"

ps -eo pid,etimes --no-headers | awk -v max="$MAX_AGE" '$2 < max {print $1}' | \
while read -r pid; do
    kill "$pid" 2>/dev/null && echo "$pid" >> "$LOG_FILE" || true
done
