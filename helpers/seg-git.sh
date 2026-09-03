#!/bin/sh
# Status segment: git branch, "*" in warn colour when dirty. Prints NOTHING
# (not even a separator) outside a repo, so no empty slot is left in the bar.
# Usage: seg-git.sh <path>      (tmux passes #{pane_current_path})
path="$1"
[ -n "$path" ] && [ -d "$path" ] || exit 0
branch=$(git -C "$path" branch --show-current 2>/dev/null) || exit 0
[ -n "$branch" ] || exit 0
if git -C "$path" diff --quiet --ignore-submodules HEAD 2>/dev/null; then
    printf '#[fg=#b2b2b2]%s  ' "$branch"
else
    printf '#[fg=#b2b2b2]%s#[fg=#ffaf00]*#[fg=#b2b2b2]  ' "$branch"
fi
