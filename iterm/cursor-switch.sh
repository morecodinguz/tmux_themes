#!/bin/sh
# Change ONLY the typing cursor -- shape and colour. Leaves the palette alone.
#
#   cursor            list them, marking the current one
#   cursor <name>     apply now and remember it
#   cursor next       cycle
SELF="$0"
while [ -L "$SELF" ]; do SELF="$(readlink "$SELF")"; done
DIR="$(cd "$(dirname "$SELF")" && pwd)"
STATE="$HOME/.config/signal-cursor"
mkdir -p "$(dirname "$STATE")"

# name    shape  colour    description
SETS="
spark|5|d7/77/57|blinking bar, warm orange
beam|6|5f/af/ff|steady bar, blue
block|2|6f/cf/7f|steady block, green
pulse|1|ff/5c/f0|blinking block, magenta
line|4|e5/a1/3a|steady underline, amber
ghost|6|8a/94/a0|steady bar, quiet grey
"
names() { printf '%s\n' "$SETS" | sed '/^$/d' | cut -d'|' -f1; }
current() { [ -r "$STATE" ] && cut -d' ' -f1 < "$STATE" || echo spark; }

emit() { # shape colour
    ESC=$(printf '\033'); BEL=$(printf '\007')
    [ -n "$TMUX" ] && E="$ESC$ESC" || E="$ESC"
    out="${E}]12;rgb:$2${BEL}${E}[$1 q"
    if [ -n "$TMUX" ]; then printf '%sPtmux;%s%s\\' "$ESC" "$out" "$ESC"
    else printf '%s' "$out"; fi
}

apply() {
    line=$(printf '%s\n' "$SETS" | grep "^$1|") || { echo "no such cursor: $1" >&2; return 1; }
    sh=$(printf '%s' "$line" | cut -d'|' -f2)
    col=$(printf '%s' "$line" | cut -d'|' -f3)
    printf '%s %s %s' "$1" "$sh" "$col" > "$STATE"
    if [ -n "$TMUX" ]; then
        for t in $(tmux list-clients -F '#{client_tty}' 2>/dev/null); do emit "$sh" "$col" > "$t" 2>/dev/null; done
    else
        emit "$sh" "$col"
    fi
    echo "cursor: $1  ($(printf '%s' "$line" | cut -d'|' -f4))"
}

case "${1-}" in
    "")   c=$(current)
          printf '%s\n' "$SETS" | sed '/^$/d' | while IFS='|' read -r n s col d; do
              [ "$n" = "$c" ] && m="*" || m=" "
              printf ' %s %-7s %s\n' "$m" "$n" "$d"
          done
          echo; echo "  cursor <name>   apply   ·   cursor next   cycle" ;;
    next) c=$(current); first=$(names | head -1); nxt=$(names | grep -A1 "^$c$" | tail -1)
          [ "$nxt" = "$c" ] && nxt="$first"
          apply "${nxt:-$first}" ;;
    *)    apply "$1" ;;
esac
