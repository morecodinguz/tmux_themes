#!/usr/bin/env bash
# Print current memory used in GB, e.g. "4.2G"
# macOS: parses vm_stat
PAGE_SIZE=$(vm_stat | awk '/page size of/ {print $8}')
[[ -z "$PAGE_SIZE" ]] && PAGE_SIZE=4096
USED_PAGES=$(vm_stat | awk '
  /Pages active/        {a=$NF}
  /Pages wired down/    {w=$NF}
  /Pages occupied by compressor/ {c=$NF}
  END { gsub(/\./,"",a); gsub(/\./,"",w); gsub(/\./,"",c); print a+w+c }')
USED_BYTES=$(( USED_PAGES * PAGE_SIZE ))
awk -v b="$USED_BYTES" 'BEGIN { printf "%.1fG\n", b/1024/1024/1024 }'
