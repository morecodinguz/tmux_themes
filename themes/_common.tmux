# ~/tmux_themes/themes/_common.tmux
# Shared options, key bindings, and shell defaults across all 11 themes.
# Sourced first by every theme's .tmux.conf.

# Terminal
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Prefix: C-a (instead of C-b)
set -g prefix C-a
unbind C-b
bind-key C-a send-prefix

# Splits: | horizontal, - vertical (uses current path)
unbind %
unbind '"'
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Pane resize: hjkl repeatable
bind -r h resize-pane -L 5
bind -r j resize-pane -D 5
bind -r k resize-pane -U 5
bind -r l resize-pane -R 5
bind -r m resize-pane -Z

# Mouse + vi mode
set -g mouse on
setw -g mode-keys vi

# Per-pane scroll: when the trackpad/wheel scrolls, force-select the pane the
# mouse is OVER (`select-pane -t =`) and scroll only THAT pane's scrollback
# via copy-mode. Without these bindings, in some terminal/iTerm2 mouse setups
# the wheel scrolls the whole terminal buffer instead of the focused pane.
#
# When the foreground app uses an alternate screen (vim, less, htop, claude),
# the wheel event is forwarded to the app so its own scrolling still works.
bind -T root WheelUpPane \
    if-shell -F -t = "#{?pane_in_mode,1,#{alternate_on}}" \
        "send-keys -M" \
        "select-pane -t = ; copy-mode -e ; send-keys -X -N 3 scroll-up"
bind -T root WheelDownPane \
    if-shell -F -t = "#{?pane_in_mode,1,#{alternate_on}}" \
        "send-keys -M" \
        "select-pane -t = ; send-keys -X -N 3 scroll-down"

# Inside copy-mode, wheel scrolls the active pane 3 lines per tick (smoother
# than the default 5).
bind -T copy-mode    WheelUpPane   send-keys -X -N 3 scroll-up
bind -T copy-mode    WheelDownPane send-keys -X -N 3 scroll-down
bind -T copy-mode-vi WheelUpPane   send-keys -X -N 3 scroll-up
bind -T copy-mode-vi WheelDownPane send-keys -X -N 3 scroll-down

# Single-keystroke scroll without prefix: Alt-k / Alt-j scrolls the active
# pane 3 lines up/down in copy-mode. Alt-K / Alt-J for half-page.
bind -n M-k copy-mode -e \; send-keys -X -N 3 scroll-up
bind -n M-j send-keys -X -N 3 scroll-down 2>/dev/null \; copy-mode -e \; send-keys -X -N 3 scroll-down

# Window/pane indices start at 1
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Faster repeat
set -sg escape-time 10
set -g repeat-time 600

# Reload bound to r
bind r source-file ~/.tmux.conf \; display-message "Reloaded ~/.tmux.conf"

# Status-bar length budgets — generous defaults so themes don't get aggressively
# truncated on narrow panes (default tmux is 10/20 chars, way too small for any
# modern theme). Per-theme confs may still override these if they need.
set -g status-left-length 250
set -g status-right-length 250

# Generous scrollback per pane — 50,000 lines means you can scroll up through
# a lot of shell history without it falling off.
set -g history-limit 50000
