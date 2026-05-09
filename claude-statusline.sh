#!/usr/bin/env bash
# Claude Code statusline — Claude-only info, fully colored.
# Renders:    Opus 4.7 (1M)  ·  ▰▰▱▱▱ 43%  ·  ⏱ 5h ▰▰▰▰▱ 87% ↻25m  ·   7d ▰▰▰▰▱ 78% ↻5d  ·   2h 0m
#
# Each segment is rendered in its own theme accent color end-to-end (bar,
# percentage, reset time) — no dim grays inside a segment. Theme colors come
# from ~/.tmux-theme so the line retunes itself on tmux-switch.

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
# 5 colors per theme: model / context / 5h / 7d / duration. Truecolor escapes.
theme=$(cat "$HOME/.tmux-theme" 2>/dev/null || echo atelier)
case "$theme" in
    glacier)            MOD='\033[38;2;180;190;254m'; CTX='\033[38;2;148;226;213m'; LIM5='\033[38;2;166;227;161m'; LIM7='\033[38;2;116;199;236m'; TIME='\033[38;2;137;220;235m' ;;
    atelier)            MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;245;194;231m'; LIM5='\033[38;2;249;226;175m'; LIM7='\033[38;2;180;190;254m'; TIME='\033[38;2;250;179;135m' ;;
    bauhaus)            MOD='\033[38;2;245;224;220m'; CTX='\033[38;2;250;179;135m'; LIM5='\033[38;2;249;226;175m'; LIM7='\033[38;2;243;139;168m'; TIME='\033[38;2;235;160;172m' ;;
    catppuccin-mocha)   MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;180;190;254m'; LIM5='\033[38;2;166;227;161m'; LIM7='\033[38;2;249;226;175m'; TIME='\033[38;2;250;179;135m' ;;
    dracula)            MOD='\033[38;2;189;147;249m'; CTX='\033[38;2;139;233;253m'; LIM5='\033[38;2;80;250;123m';  LIM7='\033[38;2;241;250;140m'; TIME='\033[38;2;255;121;198m' ;;
    rose-pine)          MOD='\033[38;2;196;167;231m'; CTX='\033[38;2;235;188;186m'; LIM5='\033[38;2;246;193;119m'; LIM7='\033[38;2;156;207;216m'; TIME='\033[38;2;234;154;151m' ;;
    tokyo-night)        MOD='\033[38;2;122;162;247m'; CTX='\033[38;2;224;175;104m'; LIM5='\033[38;2;158;206;106m'; LIM7='\033[38;2;187;154;247m'; TIME='\033[38;2;125;207;255m' ;;
    tmux-power)         MOD='\033[38;2;255;215;0m';   CTX='\033[38;2;255;175;0m';   LIM5='\033[38;2;255;140;0m';   LIM7='\033[38;2;255;255;255m'; TIME='\033[38;2;255;215;0m'   ;;
    powerline-classic)  MOD='\033[38;2;95;175;255m';  CTX='\033[38;2;255;175;0m';   LIM5='\033[38;2;135;255;135m'; LIM7='\033[38;2;255;135;215m'; TIME='\033[38;2;255;255;255m' ;;
    gruvbox)            MOD='\033[38;2;250;189;47m';  CTX='\033[38;2;184;187;38m';  LIM5='\033[38;2;254;128;25m';  LIM7='\033[38;2;211;134;155m'; TIME='\033[38;2;142;192;124m' ;;
    nova)               MOD='\033[38;2;136;192;208m'; CTX='\033[38;2;235;203;139m'; LIM5='\033[38;2;163;190;140m'; LIM7='\033[38;2;208;135;112m'; TIME='\033[38;2;180;142;173m' ;;
    *)                  MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;245;194;231m'; LIM5='\033[38;2;249;226;175m'; LIM7='\033[38;2;180;190;254m'; TIME='\033[38;2;250;179;135m' ;;
esac

DIM='\033[2m'                    # dim modifier (no color), preserves segment hue
SEP='\033[38;2;88;91;112m'
RESET='\033[0m'
BOLD='\033[1m'

# ─── helpers ──────────────────────────────────────────────────────────────
ctx_size_h=""
if [ "$ctx_size" -ge 1000000 ] 2>/dev/null; then
    ctx_size_h="$((ctx_size / 1000000))M"
elif [ "$ctx_size" -ge 1000 ] 2>/dev/null; then
    ctx_size_h="$((ctx_size / 1000))k"
fi

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

# 5-segment mini-bar (▰▰▱▱▱)
mini_bar5() {
    local pct=${1%.*}
    [ -z "$pct" ] || ! [ "$pct" -ge 0 ] 2>/dev/null && pct=0
    [ "$pct" -gt 100 ] 2>/dev/null && pct=100
    local f=$((pct / 20))
    [ $f -gt 5 ] && f=5
    local e=$((5 - f))
    local s="" i=0
    while [ "$i" -lt "$f" ]; do s="${s}▰"; i=$((i+1)); done
    i=0
    while [ "$i" -lt "$e" ]; do s="${s}▱"; i=$((i+1)); done
    echo "$s"
}

duration_h=$(fmt_duration "$duration_ms")
ctx_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null || echo 0)
ctx_bar=$(mini_bar5 "$ctx_int")

# Thinking indicator
think_mark=""
[ "$thinking" = "true" ] && think_mark=" ${BOLD}${MOD}✱${RESET}"

# ─── render ───────────────────────────────────────────────────────────────
out=""

# 1. Model + ✱
# Note: model.display_name from Claude often already includes the context size
# (e.g. "Opus 4.7 (1M context)"), so we don't append (size) ourselves to avoid
# duplicates like "Opus 4.7 (1M context) (1M)".
out+="${MOD} ${RESET} ${BOLD}${MOD}${model}${RESET}"
out+="${think_mark}"

# 2. Context — bar + % (all CTX color)
out+="  ${SEP}·${RESET}  "
out+="${CTX}${ctx_bar} ${ctx_int}%${RESET}"

# 3. 5-hour limit — bar + % + reset (all LIM5 color)
if [ -n "$rate5h_pct" ] && [ "$rate5h_pct" != "null" ]; then
    rate5h_int=$(printf '%.0f' "$rate5h_pct" 2>/dev/null || echo 0)
    rate5h_bar=$(mini_bar5 "$rate5h_int")
    until_5h=$(fmt_until "$rate5h_at")
    out+="  ${SEP}·${RESET}  "
    out+="${LIM5}⏱ 5h ${rate5h_bar} ${rate5h_int}%${RESET}"
    [ -n "$until_5h" ] && out+=" ${LIM5}${DIM}↻${until_5h}${RESET}"
fi

# 4. 7-day limit — bar + % + reset (all LIM7 color)
if [ -n "$rate7d_pct" ] && [ "$rate7d_pct" != "null" ]; then
    rate7d_int=$(printf '%.0f' "$rate7d_pct" 2>/dev/null || echo 0)
    rate7d_bar=$(mini_bar5 "$rate7d_int")
    until_7d=$(fmt_until "$rate7d_at")
    out+="  ${SEP}·${RESET}  "
    out+="${LIM7} 7d ${rate7d_bar} ${rate7d_int}%${RESET}"
    [ -n "$until_7d" ] && out+=" ${LIM7}${DIM}↻${until_7d}${RESET}"
fi

# 5. Duration — TIME color (no longer gray)
out+="  ${SEP}·${RESET}  "
out+="${TIME} ${duration_h}${RESET}"

printf '%b' "$out"
