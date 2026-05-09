#!/usr/bin/env bash
# Claude Code statusline — Claude-only info.
# Renders:    Opus 4.7 (1M)  ·  ▰▰▰▰▱▱▱▱▱▱ 43%  ·  $1.23  ·   12m
#
# No cwd / branch / user / host — those are in the tmux bar already.
# Colors are pulled from ~/.tmux-theme so the line retunes itself on tmux-switch.
#
# Wired in via ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/tmux_themes/claude-statusline.sh" }

input=$(cat)

# ─── Claude-only fields ───────────────────────────────────────────────────
model=$(echo "$input"      | jq -r '.model.display_name // "Claude"')
ctx_pct=$(echo "$input"    | jq -r '.context_window.used_percentage // 0')
ctx_size=$(echo "$input"   | jq -r '.context_window.context_window_size // 0')
cost_usd=$(echo "$input"   | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$input"| jq -r '.cost.total_duration_ms // 0')
thinking=$(echo "$input"   | jq -r '.thinking.enabled // false')

# ─── theme palette ────────────────────────────────────────────────────────
# 4 colors per theme: model / context / cost / duration. Truecolor escapes.
theme=$(cat "$HOME/.tmux-theme" 2>/dev/null || echo atelier)
case "$theme" in
    glacier)            MOD='\033[38;2;180;190;254m'; CTX='\033[38;2;148;226;213m'; COST='\033[38;2;166;227;161m'; TIME='\033[38;2;116;199;236m' ;;
    atelier)            MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;245;194;231m'; COST='\033[38;2;249;226;175m'; TIME='\033[38;2;180;190;254m' ;;
    bauhaus)            MOD='\033[38;2;245;224;220m'; CTX='\033[38;2;250;179;135m'; COST='\033[38;2;249;226;175m'; TIME='\033[38;2;243;139;168m' ;;
    catppuccin-mocha)   MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;180;190;254m'; COST='\033[38;2;166;227;161m'; TIME='\033[38;2;249;226;175m' ;;
    dracula)            MOD='\033[38;2;189;147;249m'; CTX='\033[38;2;139;233;253m'; COST='\033[38;2;80;250;123m';  TIME='\033[38;2;241;250;140m' ;;
    rose-pine)          MOD='\033[38;2;196;167;231m'; CTX='\033[38;2;235;188;186m'; COST='\033[38;2;246;193;119m'; TIME='\033[38;2;156;207;216m' ;;
    tokyo-night)        MOD='\033[38;2;122;162;247m'; CTX='\033[38;2;224;175;104m'; COST='\033[38;2;158;206;106m'; TIME='\033[38;2;187;154;247m' ;;
    tmux-power)         MOD='\033[38;2;255;215;0m';   CTX='\033[38;2;255;175;0m';   COST='\033[38;2;255;140;0m';   TIME='\033[38;2;255;255;255m' ;;
    powerline-classic)  MOD='\033[38;2;95;175;255m';  CTX='\033[38;2;255;175;0m';   COST='\033[38;2;135;255;135m'; TIME='\033[38;2;255;135;215m' ;;
    gruvbox)            MOD='\033[38;2;250;189;47m';  CTX='\033[38;2;184;187;38m';  COST='\033[38;2;254;128;25m';  TIME='\033[38;2;211;134;155m' ;;
    nova)               MOD='\033[38;2;136;192;208m'; CTX='\033[38;2;235;203;139m'; COST='\033[38;2;163;190;140m'; TIME='\033[38;2;208;135;112m' ;;
    *)                  MOD='\033[38;2;203;166;247m'; CTX='\033[38;2;245;194;231m'; COST='\033[38;2;249;226;175m'; TIME='\033[38;2;180;190;254m' ;;
esac

DIM='\033[2;38;2;108;112;134m'
SEP='\033[38;2;88;91;112m'
RESET='\033[0m'
BOLD='\033[1m'

# ─── format helpers ───────────────────────────────────────────────────────
# Context window size: 1000000 → 1M, 200000 → 200k
ctx_size_h=""
if [ "$ctx_size" -ge 1000000 ] 2>/dev/null; then
    ctx_size_h="$((ctx_size / 1000000))M"
elif [ "$ctx_size" -ge 1000 ] 2>/dev/null; then
    ctx_size_h="$((ctx_size / 1000))k"
fi

# Duration: ms → "5s" / "12m" / "1h 23m"
fmt_duration() {
    local ms=${1%.*}                       # strip any decimals
    [ -z "$ms" ] || ! [ "$ms" -ge 0 ] 2>/dev/null && { echo "0s"; return; }
    local s=$((ms / 1000))
    if [ $s -lt 60 ]; then
        echo "${s}s"
    elif [ $s -lt 3600 ]; then
        echo "$((s / 60))m"
    else
        local h=$((s / 3600))
        local m=$(((s / 60) % 60))
        echo "${h}h ${m}m"
    fi
}
duration_h=$(fmt_duration "$duration_ms")

# Cost: format to 2 decimals — but if 0, show "$0.00"
cost_h=$(printf '$%.2f' "$cost_usd" 2>/dev/null || printf '$0.00')

# Pip bar — 10 segments
ctx_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null || echo 0)
[ "$ctx_int" -gt 100 ] 2>/dev/null && ctx_int=100
filled=$((ctx_int / 10))
empty=$((10 - filled))
bar=""
i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}▰"; i=$((i+1)); done
i=0; while [ "$i" -lt "$empty"  ]; do bar="${bar}▱"; i=$((i+1)); done

# Thinking indicator — small star when extended thinking is on
think_mark=""
[ "$thinking" = "true" ] && think_mark=" ${BOLD}${MOD}✱${RESET}"

# ─── render ───────────────────────────────────────────────────────────────
# <icon> <model> [<size>] [✱]   ·   ▰▰▱▱ <pct>%   ·   $<cost>   ·   <duration>
out=""

# 1. Model
out+="${MOD} ${RESET} ${BOLD}${model}${RESET}"
[ -n "$ctx_size_h" ] && out+=" ${DIM}(${ctx_size_h})${RESET}"
out+="${think_mark}"

# 2. Context bar
out+="  ${SEP}·${RESET}  "
out+="${CTX}${bar}${RESET} ${DIM}${ctx_int}%${RESET}"

# 3. Cost
out+="  ${SEP}·${RESET}  "
out+="${COST}${cost_h}${RESET}"

# 4. Duration
out+="  ${SEP}·${RESET}  "
out+="${TIME} ${duration_h}${RESET}"

printf '%b' "$out"
