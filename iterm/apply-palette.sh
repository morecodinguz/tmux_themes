#!/bin/sh
# Replay the remembered palette at shell start. Change it with: palette <name>
[ -t 1 ] || exit 0
SELF="$0"
while [ -L "$SELF" ]; do SELF="$(readlink "$SELF")"; done
DIR="$(cd "$(dirname "$SELF")" && pwd)"
N=$(cat "$HOME/.config/signal-palette" 2>/dev/null || echo signal)
exec sh "$DIR/palette.sh" "$N"
