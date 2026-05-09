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
