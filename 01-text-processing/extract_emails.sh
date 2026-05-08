#!/bin/bash
set -euo pipefail

# recursively extracts unique email addresses from the specified directory

TARGET_DIR="${1:-/etc}"
OUT_FILE="emails.lst"

grep -R -h -o -E "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" "$TARGET_DIR" 2>/dev/null | \
sort -u | paste -sd, - > "$OUT_FILE"