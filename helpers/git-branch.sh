#!/bin/sh
# Print current pane's git branch, or nothing.
path="$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)"
[ -n "$path" ] || exit 0
git -C "$path" branch --show-current 2>/dev/null
