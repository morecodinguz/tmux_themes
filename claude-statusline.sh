#!/usr/bin/env bash
# Claude Code statusline — Claude-only info, no $$$.
# Renders:    Opus 4.7 (1M)  ·  ▰▰▰▰▱▱▱▱▱▱ 43%  ·  ⏱ 5h 18%  ·   7d 32%  ·  12m
#
# Cwd / branch / user / host are in the tmux bar already, so we omit them here
# and focus on Claude session state. Colors are pulled from ~/.tmux-theme so
# the line retunes itself on tmux-switch.
#
# Wired in via ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/tmux_themes/claude-statusline.sh" }

input=$(cat)

# ─── Claude-only fields ───────────────────────────────────────────────────
model=$(echo "$input"        | jq -r '.model.display_name // "Claude"')
ctx_pct=$(echo "$input"      | jq -r '.context_window.used_percentage // 0')
ctx_size=$(echo "$input"     | jq -r '.context_window.context_window_size // 0')
duration_ms=$(echo "$input"  | jq -r '.cost.total_duration_ms // 0')
thinking=$(echo "$input"     | jq -r '.thinking.enabled // false')
rate5h_pct=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate5h_at=$(echo "$input"    | jq -r '.rate_limits.five_hour.resets_at // empty')
rate7d_pct=$(echo "$input"   | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate7d_at=$(echo "$input"    | jq -r '.rate_limits.seven_day.resets_at // empty')

# ─── theme palette ────────────────────────────────────────────────────────
# 4 colors per theme: model / context / 5h-limit / 7d-limit. Truecolor escapes.
theme=$(cat "$HOME/.tmux-theme" 2>/dev/null || echo atelier)
case "$theme" in
    glacier)            MOD='\033[38;2;180;190;254m'; CTX='\033[38;2;148;226;213m'; LIM5='\033[38;2;166;227;161m'; LIM7='\033[38;2;116;199;236m' ;;
    atelier)            MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;245;194;231m'; LIM5='\033[38;2;249;226;175m'; LIM7='\033[38;2;180;190;254m' ;;
    bauhaus)            MOD='\033[38;2;245;224;220m'; CTX='\033[38;2;250;179;135m'; LIM5='\033[38;2;249;226;175m'; LIM7='\033[38;2;243;139;168m' ;;
    catppuccin-mocha)   MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;180;190;254m'; LIM5='\033[38;2;166;227;161m'; LIM7='\033[38;2;249;226;175m' ;;
    dracula)            MOD='\033[38;2;189;147;249m'; CTX='\033[38;2;139;233;253m'; LIM5='\033[38;2;80;250;123m';  LIM7='\033[38;2;241;250;140m' ;;
    rose-pine)          MOD='\033[38;2;196;167;231m'; CTX='\033[38;2;235;188;186m'; LIM5='\033[38;2;246;193;119m'; LIM7='\033[38;2;156;207;216m' ;;
    tokyo-night)        MOD='\033[38;2;122;162;247m'; CTX='\033[38;2;224;175;104m'; LIM5='\033[38;2;158;206;106m'; LIM7='\033[38;2;187;154;247m' ;;
    tmux-power)         MOD='\033[38;2;255;215;0m';   CTX='\033[38;2;255;175;0m';   LIM5='\033[38;2;255;140;0m';   LIM7='\033[38;2;255;255;255m' ;;
    powerline-classic)  MOD='\033[38;2;95;175;255m';  CTX='\033[38;2;255;175;0m';   LIM5='\033[38;2;135;255;135m'; LIM7='\033[38;2;255;135;215m' ;;
    gruvbox)            MOD='\033[38;2;250;189;47m';  CTX='\033[38;2;184;187;38m';  LIM5='\033[38;2;254;128;25m';  LIM7='\033[38;2;211;134;155m' ;;
    nova)               MOD='\033[38;2;136;192;208m'; CTX='\033[38;2;235;203;139m'; LIM5='\033[38;2;163;190;140m'; LIM7='\033[38;2;208;135;112m' ;;
    *)                  MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;245;194;231m'; LIM5='\033[38;2;249;226;175m'; LIM7='\033[38;2;180;190;254m' ;;
esac

DIM='\033[2;38;2;108;112;134m'
SEP='\033[38;2;88;91;112m'
RESET='\033[0m'
BOLD='\033[1m'

# ─── helpers ──────────────────────────────────────────────────────────────
# Context window size: 1000000 → 1M, 200000 → 200k
ctx_size_h=""
if [ "$ctx_size" -ge 1000000 ] 2>/dev/null; then
    ctx_size_h="$((ctx_size / 1000000))M"
elif [ "$ctx_size" -ge 1000 ] 2>/dev/null; then
    ctx_size_h="$((ctx_size / 1000))k"
fi

# Duration: ms → "5s" / "12m" / "1h 23m"
fmt_duration() {
    local ms=${1%.*}
    [ -z "$ms" ] || ! [ "$ms" -ge 0 ] 2>/dev/null && { echo "0s"; return; }
    local s=$((ms / 1000))
    if [ $s -lt 60 ]; then
        echo "${s}s"
    elif [ $s -lt 3600 ]; then
        echo "$((s / 60))m"
    else
        echo "$((s / 3600))h $(((s / 60) % 60))m"
    fi
}

# "Resets in" formatter: epoch seconds → "12m" / "2h" / "3d"
fmt_until() {
    local target=${1%.*}
    [ -z "$target" ] || ! [ "$target" -gt 0 ] 2>/dev/null && return
    local now
    now=$(date +%s)
    local delta=$((target - now))
    if [ "$delta" -le 0 ]; then
        echo "now"
    elif [ "$delta" -lt 3600 ]; then
        echo "$((delta / 60))m"
    elif [ "$delta" -lt 86400 ]; then
        echo "$((delta / 3600))h"
    else
        echo "$((delta / 86400))d"
    fi
}

# Pip bar — 10 segments
pip_bar() {
    local pct=${1%.*}
    [ -z "$pct" ] || ! [ "$pct" -ge 0 ] 2>/dev/null && pct=0
    [ "$pct" -gt 100 ] 2>/dev/null && pct=100
    local filled=$((pct / 10))
    local empty=$((10 - filled))
    local bar=""
    local i=0
    while [ "$i" -lt "$filled" ]; do bar="${bar}▰"; i=$((i+1)); done
    i=0
    while [ "$i" -lt "$empty"  ]; do bar="${bar}▱"; i=$((i+1)); done
    echo "$bar"
}

duration_h=$(fmt_duration "$duration_ms")
ctx_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null || echo 0)
ctx_bar=$(pip_bar "$ctx_int")

# Thinking indicator — small star when extended thinking is on
think_mark=""
[ "$thinking" = "true" ] && think_mark=" ${BOLD}${MOD}✱${RESET}"

# ─── render ───────────────────────────────────────────────────────────────
# 1. Model + context size + thinking ✱
out=""
out+="${MOD} ${RESET} ${BOLD}${model}${RESET}"
[ -n "$ctx_size_h" ] && out+=" ${DIM}(${ctx_size_h})${RESET}"
out+="${think_mark}"

# 2. Context bar + %
out+="  ${SEP}·${RESET}  "
out+="${CTX}${ctx_bar}${RESET} ${DIM}${ctx_int}%${RESET}"

# 3. 5-hour rate limit (only if data is present)
if [ -n "$rate5h_pct" ] && [ "$rate5h_pct" != "null" ]; then
    rate5h_int=$(printf '%.0f' "$rate5h_pct" 2>/dev/null || echo 0)
    until_5h=$(fmt_until "$rate5h_at")
    out+="  ${SEP}·${RESET}  "
    out+="${LIM5}⏱ 5h ${rate5h_int}%${RESET}"
    [ -n "$until_5h" ] && out+=" ${DIM}↻${until_5h}${RESET}"
fi

# 4. 7-day rate limit (only if data is present)
if [ -n "$rate7d_pct" ] && [ "$rate7d_pct" != "null" ]; then
    rate7d_int=$(printf '%.0f' "$rate7d_pct" 2>/dev/null || echo 0)
    until_7d=$(fmt_until "$rate7d_at")
    out+="  ${SEP}·${RESET}  "
    out+="${LIM7} 7d ${rate7d_int}%${RESET}"
    [ -n "$until_7d" ] && out+=" ${DIM}↻${until_7d}${RESET}"
fi

# 5. Session duration
out+="  ${SEP}·${RESET}  "
out+="${DIM} ${duration_h}${RESET}"

printf '%b' "$out"
