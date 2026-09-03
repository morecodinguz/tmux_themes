#!/bin/sh
# Try a palette instantly, or make it permanent.
#
#   palette              list them, showing the current one
#   palette <name>       apply now and remember it
#   palette next         cycle to the next one
SELF="$0"
while [ -L "$SELF" ]; do SELF="$(readlink "$SELF")"; done
DIR="$(cd "$(dirname "$SELF")" && pwd)"
STATE="$HOME/.config/signal-palette"
mkdir -p "$(dirname "$STATE")"
current() { [ -r "$STATE" ] && cat "$STATE" || echo signal; }
names() { for f in "$DIR"/palettes/*.conf; do basename "$f" .conf; done; }

apply() {
    n="$1"
    [ -r "$DIR/palettes/$n.conf" ] || { echo "no such palette: $n" >&2; return 1; }
    printf '%s' "$n" > "$STATE"
    if [ -n "$TMUX" ]; then
        for t in $(tmux list-clients -F '#{client_tty}' 2>/dev/null); do
            sh "$DIR/palette.sh" "$n" > "$t" 2>/dev/null
        done
    else
        sh "$DIR/palette.sh" "$n"
    fi
    echo "palette: $n"
}

case "${1-}" in
    "")   c=$(current)
          for n in $(names); do
              . "$DIR/palettes/$n.conf"
              [ "$n" = "$c" ] && m="*" || m=" "
              printf ' %s %-9s %s\n' "$m" "$n" "$DESC"
          done
          echo; echo "  palette <name>   apply     ·   palette next   cycle" ;;
    next) c=$(current); set -- $(names); first="$1"; found=0; nxt=""
          for n in "$@"; do
              [ "$found" = 1 ] && { nxt="$n"; break; }
              [ "$n" = "$c" ] && found=1
          done
          apply "${nxt:-$first}" ;;
    *)    apply "$1" ;;
esac
