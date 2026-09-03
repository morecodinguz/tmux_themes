#!/bin/sh
# Emit one palette as escape sequences on stdout. Usage: palette.sh <name>
#
# tmux note: inside tmux every ESC must be DOUBLED and the payload wrapped in a
# DCS passthrough. Do not use sed for that -- BSD sed ignores \o033 silently.
SELF="$0"
while [ -L "$SELF" ]; do SELF="$(readlink "$SELF")"; done
DIR="$(cd "$(dirname "$SELF")" && pwd)"
NAME="${1:-signal}"
CONF="$DIR/palettes/$NAME.conf"
[ -r "$CONF" ] || { echo "no such palette: $NAME" >&2; exit 1; }
# shellcheck disable=SC1090
. "$CONF"

ESC=$(printf '\033'); BEL=$(printf '\007')
[ -n "$TMUX" ] && E="$ESC$ESC" || E="$ESC"

out=""; i=0
for c in $ANSI; do
    out="${out}${E}]4;${i};rgb:$(printf '%s' "$c" | cut -c1-2)/$(printf '%s' "$c" | cut -c3-4)/$(printf '%s' "$c" | cut -c5-6)${BEL}"
    i=$((i+1))
done
hx() { printf '%s/%s/%s' "$(printf '%s' "$1"|cut -c1-2)" "$(printf '%s' "$1"|cut -c3-4)" "$(printf '%s' "$1"|cut -c5-6)"; }
out="${out}${E}]10;rgb:$(hx "$FG")${BEL}"
out="${out}${E}]11;rgb:$(hx "$BG")${BEL}"
# The cursor is chosen separately with `cursor <name>`; honour that choice so
# switching palettes never overrides it. Falls back to the palette's own.
CSTATE="$HOME/.config/signal-cursor"
if [ -r "$CSTATE" ]; then
    SHAPE=$(cut -d' ' -f2 < "$CSTATE")
    CURSOR_RGB=$(cut -d' ' -f3 < "$CSTATE")
else
    CURSOR_RGB=$(hx "$CURSOR")
fi
out="${out}${E}]12;rgb:${SIGNAL_CURSOR_COLOR:-$CURSOR_RGB}${BEL}"
out="${out}${E}[${SIGNAL_CURSOR:-$SHAPE} q"

# Selection. OSC 17/19 is the xterm way; iTerm2 also accepts its own
# SetColors, and honours whichever it understands. Both are harmless elsewhere.
out="${out}${E}]17;rgb:$(hx "$SEL_BG")${BEL}"
out="${out}${E}]19;rgb:$(hx "$SEL_FG")${BEL}"
out="${out}${E}]1337;SetColors=selbg=${SEL_BG}${BEL}"
out="${out}${E}]1337;SetColors=selfg=${SEL_FG}${BEL}"

if [ -n "$TMUX" ]; then printf '%sPtmux;%s%s\\' "$ESC" "$out" "$ESC"
else printf '%s' "$out"; fi
