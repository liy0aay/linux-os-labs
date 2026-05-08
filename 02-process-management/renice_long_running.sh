#!/bin/bash
set -euo pipefail

# modifies the scheduling priority of processes running longer than N seconds

if [[ $# -eq 0 ]]; then
    echo "usage: $0 <min_age_seconds> [nice_increment]"
    exit 1
fi

MIN_AGE="$1"
NICE_INC="${2:-10}"

ps -eo pid,etimes --no-headers | awk -v min="$MIN_AGE" '$2 > min {print $1}' | \
while read -r pid; do
    renice "$NICE_INC" -p "$pid" >/dev/null 2>&1 || true
done

echo "Current top oldest processes and their nice values:"
ps -eo pid,ni,etimes,comm --sort=-etimes | head -n 15