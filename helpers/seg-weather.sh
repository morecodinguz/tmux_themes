#!/bin/sh
# Status segment: temperature, or nothing at all when it is unavailable.
out=$("$(dirname "$0")/weather.sh" 2>/dev/null)
[ -n "$out" ] || exit 0
printf '#[fg=#7f7f7f]%s  ' "$out"
