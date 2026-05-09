#!/usr/bin/env bash
# Print a short version of the current pane's working directory.
# /Users/daniel/code/tmux  →  ~/code/tmux
# /Users/daniel/work/projects/foo/src/lib  →  …/foo/src/lib (last 3 components)
p=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
[[ -z "$p" ]] && exit 0
p="${p/#$HOME/~}"
# Trim to last 3 components if too deep
IFS=/ read -r -a parts <<<"$p"
n=${#parts[@]}
if [[ $n -gt 4 ]]; then
    echo "…/${parts[n-3]}/${parts[n-2]}/${parts[n-1]}"
else
    echo "$p"
fi
