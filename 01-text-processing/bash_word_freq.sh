#!/bin/bash
set -euo pipefail

# calculates the top N most frequent words (4+ chars) in a given man page

MAN_PAGE="${1:-bash}"
TOP_N="${2:-3}"

man "$MAN_PAGE" | \
tr '[:upper:]' '[:lower:]' | \
tr -c 'a-z' '\n' | \
grep -E '^.{4,}$' | \
sort | \
uniq -c | \
sort -k1r | \
head -n "$TOP_N"

