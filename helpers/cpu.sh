#!/usr/bin/env bash
# Print current CPU % (user+sys), e.g. "38%"
top -l 1 -n 0 2>/dev/null | awk '/CPU usage/ {gsub(/%/,"",$3); gsub(/%/,"",$5); printf "%.0f%%\n", $3 + $5}'
