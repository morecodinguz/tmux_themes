#!/usr/bin/env bash
# Print the public IP (your WAN address as seen from the internet).
# Cached for 15 minutes to avoid hitting the network on every status refresh.
CACHE="$HOME/.cache/tmux-ip-public"
mkdir -p "$(dirname "$CACHE")"
MAX_AGE=900   # 15 minutes

if [[ -f "$CACHE" ]]; then
    age=$(( $(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
    if [[ "$age" -lt "$MAX_AGE" && -s "$CACHE" ]]; then
        cat "$CACHE"
        exit 0
    fi
fi

ip=$(curl -s --max-time 2 https://icanhazip.com 2>/dev/null | tr -d '[:space:]')
if [[ -n "$ip" ]]; then
    echo -n "$ip" > "$CACHE"
    echo "$ip"
else
    # Fall back to last cached value if available, even if stale
    [[ -s "$CACHE" ]] && cat "$CACHE" || echo "—"
fi
