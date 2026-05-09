#!/bin/sh
# Print "branch ✓" if clean, "branch *" if dirty, nothing if not a repo.
path="$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)"
[ -n "$path" ] || exit 0
branch="$(git -C "$path" branch --show-current 2>/dev/null)"
[ -n "$branch" ] || exit 0
if git -C "$path" diff --quiet --ignore-submodules HEAD 2>/dev/null; then
    printf '%s ✓' "$branch"
else
    printf '%s *' "$branch"
fi
