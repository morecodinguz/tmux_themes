#!/usr/bin/env bash
# tmux-switch — switch between 11 tmux themes.
#
# Usage:
#   tmux-switch                cycle to next theme
#   tmux-switch prev           cycle to previous theme
#   tmux-switch list           interactive fzf picker (arrow keys + enter)
#   tmux-switch <name>         jump to a specific theme
#   tmux-switch -h | --help    show help
#
# Themes live in ~/tmux_themes/themes/<name>.tmux.conf with metadata in _meta.tsv

set -euo pipefail

THEMES_DIR="$HOME/tmux_themes/themes"
META_FILE="$THEMES_DIR/_meta.tsv"
THEME_FILE="$HOME/.tmux-theme"
TMUX_CONF="$HOME/.tmux.conf"

# Read theme order from _meta.tsv (cycle order = file order)
read_themes() {
    awk -F'\t' '$1 != "" && $1 !~ /^#/ {print $1}' "$META_FILE"
}

current_theme() {
    [[ -f "$THEME_FILE" ]] && cat "$THEME_FILE" || echo "glacier"
}

list_themes() {
    awk -F'\t' '$1 != "" && $1 !~ /^#/ {printf "%-22s %s\n", $1, $2}' "$META_FILE"
}

usage() {
    cat <<EOF
tmux-switch — 11-theme switcher

Usage:
  tmux-switch              cycle to next theme
  tmux-switch prev         cycle to previous theme
  tmux-switch list         interactive picker (fzf)
  tmux-switch <name>       jump to theme
  tmux-switch -h           show this help

Available themes:
EOF
    list_themes | sed 's/^/  /'
    echo
    echo "Current theme: $(current_theme)"
}

# Move N steps through the theme list (positive=forward, negative=backward)
step_theme() {
    local current="$1" step="$2"
    local themes
    mapfile -t themes < <(read_themes)
    local n=${#themes[@]} i
    for i in "${!themes[@]}"; do
        if [[ "${themes[$i]}" == "$current" ]]; then
            local next=$(( (i + step + n) % n ))
            echo "${themes[$next]}"
            return
        fi
    done
    echo "${themes[0]}"
}

apply_theme() {
    local theme="$1"
    local conf="$THEMES_DIR/$theme.tmux.conf"
    if [[ ! -f "$conf" ]]; then
        echo "Unknown theme: $theme" >&2
        echo "Run 'tmux-switch list' to see available themes." >&2
        exit 1
    fi

    rm -f "$TMUX_CONF"
    ln -s "$conf" "$TMUX_CONF"
    echo "$theme" > "$THEME_FILE"

    if tmux info >/dev/null 2>&1; then
        tmux source-file "$TMUX_CONF" 2>/dev/null || true
        tmux refresh-client -S 2>/dev/null || true
        echo "Switched to $theme ✓"
        echo "Tip: if status-bar artifacts remain from the previous theme, run: tmux kill-server"
    else
        echo "Switched to $theme ✓ (no tmux server running; will load on next start)"
    fi
}

# Interactive picker via fzf, prefilled with current theme
pick_theme() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf not installed. Install with: brew install fzf" >&2
        echo "Falling back to list output:"
        list_themes
        exit 1
    fi

    local current
    current="$(current_theme)"

    local picked
    picked=$(list_themes | fzf \
        --prompt="Theme › " \
        --header="Current: $current  •  ↑↓ select  •  Enter apply  •  Esc cancel" \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --color="border:#cba6f7,prompt:#cba6f7,header:#9399b2,pointer:#cba6f7,info:#7f849c" \
        --query="" \
        --bind="ctrl-/:change-preview-window(hidden|)" \
        --no-sort) || return 0

    [[ -n "$picked" ]] || return 0
    local name
    name=$(awk '{print $1}' <<<"$picked")
    apply_theme "$name"
}

# Dispatch
case "${1-}" in
    "")              apply_theme "$(step_theme "$(current_theme)" +1)" ;;
    prev|previous)   apply_theme "$(step_theme "$(current_theme)" -1)" ;;
    next)            apply_theme "$(step_theme "$(current_theme)" +1)" ;;
    list|pick|menu)  pick_theme ;;
    -h|--help|help)  usage ;;
    *)               apply_theme "$1" ;;
esac
