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
    # shellcheck disable=SC1090
    . "$DIR/palettes/$n.conf"

    # 1. terminal: the 16 ANSI colours, ground, foreground and cursor
    if [ -n "$TMUX" ]; then
        for t in $(tmux list-clients -F '#{client_tty}' 2>/dev/null); do
            sh "$DIR/palette.sh" "$n" > "$t" 2>/dev/null
        done
    else
        sh "$DIR/palette.sh" "$n"
    fi

    # 2. Claude Code: rewrite the theme file it already has selected, so the
    #    chat re-colours without changing which theme is chosen. The theme
    #    directory is watched, so this applies without restarting.
    T="$HOME/.claude/themes/signal.json"
    if [ -d "$(dirname "$T")" ]; then
        cat > "$T" <<JSON
{
  "name": "Signal",
  "base": "dark",
  "overrides": {
    "userMessageBackground": "#$CC_USER",
    "userMessageBackgroundHover": "#$CC_USER",
    "bashMessageBackgroundColor": "#$CC_BASH",
    "memoryBackgroundColor": "#$CC_MEM",
    "bashBorder": "#$CC_ACCENT",
    "claude": "#$CC_CLAUDE",
    "claudeShimmer": "#$CC_CLAUDE",
    "permission": "#$CC_ACCENT",
    "suggestion": "#$CC_ACCENT",
    "remember": "#$CC_ACCENT",
    "planMode": "#$CC_ACCENT",
    "autoAccept": "#$CC_ACCENT",
    "skill": "#$CC_ACCENT",
    "success": "#$CC_OK",
    "error": "#$CC_ERR",
    "warning": "#$CC_WARN",
    "selectionBg": "#$SEL_BG",
    "subtle": "#$CC_SUBTLE",
    "inactive": "#$CC_SUBTLE"
  }
}
JSON
    fi

    # 3. tmux: pane grounds, borders, selection and the status bar.
    # One call per option on purpose -- a single chained `tmux a \; b \; c`
    # breaks silently the moment a line-continuation backslash goes missing,
    # and the leftovers then run as the shell's own `set` builtin.
    if [ -n "$TMUX" ]; then
        tmux set -g window-style                  "bg=#$TM_INACTIVE"
        tmux set -g window-active-style           "bg=#$TM_BG"
        tmux set -g pane-border-style             "fg=#$TM_BORDER"
        tmux set -g pane-active-border-style      "fg=#$TM_ACCENT"
        tmux set -g status-style                  "bg=#$TM_BG,fg=#$TM_DIM"
        tmux set -g message-style                 "bg=#$TM_ACCENT,fg=#$TM_BG"
        tmux set -g mode-style                    "bg=#$SEL_BG,fg=#$SEL_FG"
        tmux set -g copy-mode-match-style         "bg=#$SEL_MATCH,fg=#$TM_BG"
        tmux set -g copy-mode-current-match-style "bg=#$TM_ACCENT,fg=#$TM_BG"
        tmux set -g status-left "#{?client_prefix,#[fg=#$TM_WARN]●,#[fg=#$TM_BORDER]●} #[fg=#$TM_BG,bg=#$TM_ACCENT,bold] #S #[fg=#$TM_ACCENT,bg=#$TM_BG] "
        tmux setw -g window-status-format         "#[fg=#$TM_DIM] #I #W#{?window_zoomed_flag,#[fg=#$TM_WARN]Z,}#{?window_activity_flag,#[fg=#$TM_WARN]!,} "
        tmux setw -g window-status-current-format "#[fg=#$TM_ACCENT,bold] #I #W#{?window_zoomed_flag,#[fg=#$TM_WARN]Z,} "
        tmux refresh-client -S 2>/dev/null
    fi

    echo "palette: $n   (terminal + Claude Code + tmux)"
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
