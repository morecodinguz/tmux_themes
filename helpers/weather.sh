#!/usr/bin/env bash
# Print local weather as just the temp ("20.6°C").
# Cached for 30 minutes. Uses wttr.in (no API key needed).
CACHE="$HOME/.cache/tmux-weather"
mkdir -p "$(dirname "$CACHE")"
MAX_AGE=1800   # 30 minutes

if [[ -f "$CACHE" ]]; then
    age=$(( $(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
    if [[ "$age" -lt "$MAX_AGE" && -s "$CACHE" ]]; then
        cat "$CACHE"
        exit 0
    fi
fi

# %t = temperature only, e.g. "+20°C". Strip the leading +.
out=$(curl -s --max-time 3 'https://wttr.in/?format=%t' 2>/dev/null | tr -d '+\n')
# Only accept responses that actually look like a temperature (e.g. "20°C").
# This rejects wttr.in error bodies like "location not found: sqlite read
# failed: ..." which would otherwise poison the cache and display forever.
if [[ "$out" == *"°"* && "$out" =~ [0-9] ]]; then
    echo -n "$out" > "$CACHE"
    echo "$out"
else
    [[ -s "$CACHE" ]] && cat "$CACHE" || echo ""
fi
