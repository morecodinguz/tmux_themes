#!/bin/sh
# Status segment: battery. Neutral normally, warn colour at 20% or below.
# Silent while on AC at 100% -- a plugged-in full battery is not information.
line=$(pmset -g batt 2>/dev/null) || exit 0
pct=$(printf '%s' "$line" | grep -Eo '[0-9]+%' | head -n1 | tr -d '%')
[ -n "$pct" ] || exit 0
case "$line" in
    *"AC Power"*) [ "$pct" -ge 100 ] && exit 0 ;;
esac
if [ "$pct" -le 20 ]; then
    printf '#[fg=#ffaf00]bat %s%%  ' "$pct"
else
    printf '#[fg=#7f7f7f]bat %s%%  ' "$pct"
fi
