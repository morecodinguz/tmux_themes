#!/usr/bin/env bash
# Claude Code statusline — Claude-only info, width-adaptive.
#
# Three layouts based on the pane width:
#   FULL   (≥120 cols)   Opus 4.7 (1M context) ✱  ·  ▰▰▱▱▱ 43%  ·  ⏱ 5h ▰▰▰▰▱ 87% ↻25m  ·   7d ▰▰▰▰▱ 78% ↻5d  ·   12m
#   MEDIUM ( 80–119)     Opus 4.7 ✱  ·  ▰▰▱▱▱ 43%  ·  ⏱ 5h 87% ↻25m  ·   7d 78% ↻5d  ·   12m
#   NARROW (<80)         Opus 4.7  ·  ▰▰▱▱▱ 43%  ·  5h 87%  ·  7d 78%
#
# Colors come from ~/.tmux-theme so the line retunes itself on tmux-switch.

input=$(cat)

# ─── width detection ──────────────────────────────────────────────────────
# Inside tmux the pane width is authoritative. Outside, fall back to COLUMNS
# (set by the parent shell) or tput cols (rarely works in this subshell).
cols=""
if [[ -n "$TMUX" ]]; then
    cols=$(tmux display-message -p '#{pane_width}' 2>/dev/null)
fi
[[ -z "$cols" ]] && cols="${COLUMNS:-}"
[[ -z "$cols" ]] && cols=$(tput cols 2>/dev/null)
[[ -z "$cols" ]] && cols=120

if   [[ "$cols" -lt 80 ]];  then layout=narrow
elif [[ "$cols" -lt 120 ]]; then layout=medium
else                             layout=full
fi

# ─── Claude-only fields ───────────────────────────────────────────────────
model=$(echo "$input"        | jq -r '.model.display_name // "Claude"')
ctx_pct=$(echo "$input"      | jq -r '.context_window.used_percentage // 0')
duration_ms=$(echo "$input"  | jq -r '.cost.total_duration_ms // 0')
thinking=$(echo "$input"     | jq -r '.thinking.enabled // false')
rate5h_pct=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate5h_at=$(echo "$input"    | jq -r '.rate_limits.five_hour.resets_at // empty')
rate7d_pct=$(echo "$input"   | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate7d_at=$(echo "$input"    | jq -r '.rate_limits.seven_day.resets_at // empty')

# ─── theme palette ────────────────────────────────────────────────────────
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

DIM='\033[2m'
SEP='\033[38;2;88;91;112m'
RESET='\033[0m'
BOLD='\033[1m'

# ─── helpers ──────────────────────────────────────────────────────────────
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
    if [ "$delta" -le 0 ]; then echo "now"
    elif [ "$delta" -lt 3600 ]; then echo "$((delta / 60))m"
    elif [ "$delta" -lt 86400 ]; then echo "$((delta / 3600))h"
    else echo "$((delta / 86400))d"
    fi
}

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

# Short model name — strip parenthetical "(1M context)" for narrow layouts
model_short=$(echo "$model" | sed -E 's/ *\([^)]*\)$//')

think_mark=""
[ "$thinking" = "true" ] && think_mark=" ${BOLD}${MOD}✱${RESET}"

# ─── render ───────────────────────────────────────────────────────────────
out=""
sep="  ${SEP}·${RESET}  "

case "$layout" in
    narrow)
        # 1. Model (short) + ✱
        out+="${MOD}${RESET} ${BOLD}${MOD}${model_short}${RESET}${think_mark}"
        # 2. Context bar + %
        out+="${sep}${CTX}${ctx_bar} ${ctx_int}%${RESET}"
        # 3. 5h limit — bar + % (no reset, no ⏱ icon to save space)
        if [ -n "$rate5h_pct" ] && [ "$rate5h_pct" != "null" ]; then
            r=$(printf '%.0f' "$rate5h_pct" 2>/dev/null || echo 0)
            r_bar=$(mini_bar5 "$r")
            out+="${sep}${LIM5}5h ${r_bar} ${r}%${RESET}"
        fi
        # 4. 7d limit — bar + %
        if [ -n "$rate7d_pct" ] && [ "$rate7d_pct" != "null" ]; then
            r=$(printf '%.0f' "$rate7d_pct" 2>/dev/null || echo 0)
            r_bar=$(mini_bar5 "$r")
            out+="${sep}${LIM7}7d ${r_bar} ${r}%${RESET}"
        fi
        ;;

    medium)
        # 1. Model (short) + ✱
        out+="${MOD}${RESET} ${BOLD}${MOD}${model_short}${RESET}${think_mark}"
        # 2. Context bar + %
        out+="${sep}${CTX}${ctx_bar} ${ctx_int}%${RESET}"
        # 3. 5h limit — bar + % + reset (D-style: bar always)
        if [ -n "$rate5h_pct" ] && [ "$rate5h_pct" != "null" ]; then
            r=$(printf '%.0f' "$rate5h_pct" 2>/dev/null || echo 0)
            r_bar=$(mini_bar5 "$r")
            until_5h=$(fmt_until "$rate5h_at")
            out+="${sep}${LIM5}⏱ 5h ${r_bar} ${r}%${RESET}"
            [ -n "$until_5h" ] && out+=" ${LIM5}${DIM}↻${until_5h}${RESET}"
        fi
        # 4. 7d limit — bar + % + reset
        if [ -n "$rate7d_pct" ] && [ "$rate7d_pct" != "null" ]; then
            r=$(printf '%.0f' "$rate7d_pct" 2>/dev/null || echo 0)
            r_bar=$(mini_bar5 "$r")
            until_7d=$(fmt_until "$rate7d_at")
            out+="${sep}${LIM7} 7d ${r_bar} ${r}%${RESET}"
            [ -n "$until_7d" ] && out+=" ${LIM7}${DIM}↻${until_7d}${RESET}"
        fi
        # 5. Duration
        out+="${sep}${TIME} ${duration_h}${RESET}"
        ;;

    full|*)
        # 1. Full model name + ✱
        out+="${MOD} ${RESET} ${BOLD}${MOD}${model}${RESET}${think_mark}"
        # 2. Context
        out+="${sep}${CTX}${ctx_bar} ${ctx_int}%${RESET}"
        # 3. 5h with inner bar + reset
        if [ -n "$rate5h_pct" ] && [ "$rate5h_pct" != "null" ]; then
            r=$(printf '%.0f' "$rate5h_pct" 2>/dev/null || echo 0)
            r_bar=$(mini_bar5 "$r")
            until_5h=$(fmt_until "$rate5h_at")
            out+="${sep}${LIM5}⏱ 5h ${r_bar} ${r}%${RESET}"
            [ -n "$until_5h" ] && out+=" ${LIM5}${DIM}↻${until_5h}${RESET}"
        fi
        # 4. 7d with inner bar + reset
        if [ -n "$rate7d_pct" ] && [ "$rate7d_pct" != "null" ]; then
            r=$(printf '%.0f' "$rate7d_pct" 2>/dev/null || echo 0)
            r_bar=$(mini_bar5 "$r")
            until_7d=$(fmt_until "$rate7d_at")
            out+="${sep}${LIM7} 7d ${r_bar} ${r}%${RESET}"
            [ -n "$until_7d" ] && out+=" ${LIM7}${DIM}↻${until_7d}${RESET}"
        fi
        # 5. Duration
        out+="${sep}${TIME} ${duration_h}${RESET}"
        ;;
esac

printf '%b' "$out"
