#!/usr/bin/env bash
# Claude Code statusline.
# Renders:    ~/tmux_themes  ·   main  ·   Opus 4.7  ·  ▰▰▰▰▱▱▱▱▱▱ 43%
# Colors are picked from ~/.tmux-theme so the statusline matches the active
# tmux theme's palette. Falls back to atelier if the theme file is missing.
#
# Wired in via ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/tmux_themes/claude-statusline.sh" }

input=$(cat)

cwd=$(echo "$input"     | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input"   | jq -r '.model.display_name // "Claude"')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# ─── theme palette ────────────────────────────────────────────────────────
# Three colors per theme: dir/accent, branch, context. All truecolor escapes.
theme=$(cat "$HOME/.tmux-theme" 2>/dev/null || echo atelier)
case "$theme" in
    glacier)            ACC='\033[38;2;180;190;254m'; BR='\033[38;2;116;199;236m'; CTX='\033[38;2;148;226;213m' ;;
    atelier)            ACC='\033[38;2;203;166;247m'; BR='\033[38;2;250;179;135m'; CTX='\033[38;2;245;194;231m' ;;
    bauhaus)            ACC='\033[38;2;245;224;220m'; BR='\033[38;2;243;139;168m'; CTX='\033[38;2;250;179;135m' ;;
    catppuccin-mocha)   ACC='\033[38;2;203;166;247m'; BR='\033[38;2;166;227;161m'; CTX='\033[38;2;180;190;254m' ;;
    dracula)            ACC='\033[38;2;189;147;249m'; BR='\033[38;2;255;121;198m'; CTX='\033[38;2;241;250;140m' ;;
    rose-pine)          ACC='\033[38;2;196;167;231m'; BR='\033[38;2;246;193;119m'; CTX='\033[38;2;235;188;186m' ;;
    tokyo-night)        ACC='\033[38;2;122;162;247m'; BR='\033[38;2;187;154;247m'; CTX='\033[38;2;224;175;104m' ;;
    tmux-power)         ACC='\033[38;2;255;215;0m';   BR='\033[38;2;255;175;0m';   CTX='\033[38;2;255;140;0m'   ;;
    powerline-classic)  ACC='\033[38;2;95;175;255m';  BR='\033[38;2;135;255;135m'; CTX='\033[38;2;255;175;0m'   ;;
    gruvbox)            ACC='\033[38;2;250;189;47m';  BR='\033[38;2;254;128;25m';  CTX='\033[38;2;184;187;38m'  ;;
    nova)               ACC='\033[38;2;136;192;208m'; BR='\033[38;2;163;190;140m'; CTX='\033[38;2;235;203;139m' ;;
    *)                  ACC='\033[38;2;203;166;247m'; BR='\033[38;2;250;179;135m'; CTX='\033[38;2;245;194;231m' ;;
esac

DIM='\033[2;38;2;108;112;134m'   # overlay0 dim
SEP='\033[38;2;88;91;112m'       # surface2 separator
RESET='\033[0m'
BOLD='\033[1m'

# ─── data ─────────────────────────────────────────────────────────────────
# Shorten home prefix to ~ via sed (bash's ${var/#$HOME/~} treats ~ as
# tilde-expansion, not a literal — sed avoids that).
short_cwd=$(printf '%s' "$cwd" | sed "s|^$HOME|~|")

branch=""
[ -n "$cwd" ] && branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# Pip bar — 10 segments, filled vs empty
ctx_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null || echo 0)
[ "$ctx_int" -gt 100 ] && ctx_int=100
filled=$((ctx_int / 10))
empty=$((10 - filled))
bar=""
i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}▰"; i=$((i+1)); done
i=0; while [ "$i" -lt "$empty"  ]; do bar="${bar}▱"; i=$((i+1)); done

# ─── render ───────────────────────────────────────────────────────────────
# Layout:   <icon> <dir>  ·   <icon> <branch>  ·   <icon> <model>  ·  <bar> <pct>%
# Separator is a middle dot in surface2; icons in theme accent; values in bright text.

# Directory segment
out=""
out+="${ACC} ${RESET} ${BOLD}${short_cwd}${RESET}"

# Branch segment (only if in a git repo)
if [ -n "$branch" ]; then
    out+="  ${SEP}·${RESET}  "
    out+="${BR} ${RESET} ${branch}"
fi

# Model segment
out+="  ${SEP}·${RESET}  "
out+="${ACC} ${RESET} ${DIM}${model}${RESET}"

# Context bar
out+="  ${SEP}·${RESET}  "
out+="${CTX}${bar}${RESET} ${DIM}${ctx_int}%${RESET}"

printf '%b' "$out"
