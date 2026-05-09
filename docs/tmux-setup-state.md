# Project State — Tmux 3-Theme Switcher
> Last updated: 2026-05-08 by Session #7

## Project Type
Dotfiles / Hybrid (tmux config + helper scripts)

## Current Phase
Quality (per-theme temperature identity applied — ADR-009)

## Progress
Theme switcher functional; all 3 themes have distinct bg + bar palettes (cool / pastel / warm temperature). Backups + restore script live at `~/.tmux-backups/2026-05-08-pre-redesign/`.

## Tech Stack (locked)
- tmux (Homebrew, macOS)
- tmux2k plugin (`~/.tmux/plugins/tmux2k`) using catppuccin palette
- catppuccin theme — manual styling (no plugin status modules)
- gpakosz/.tmux (oh-my-tmux) at `~/ohmytmux-src/`
- Font: JetBrainsMono Nerd Font Mono (iTerm2 profile)
- Shell: zsh (default) + bash (Homebrew at `/opt/homebrew/bin/bash` for tmux2k scripts)
- Switcher: `~/.tmux-switch.sh` (symlink-based, 3 themes)

## Active Module
None — session ended after applying refinements.

## Completed (this session, #7)
- Backed up all configs to `~/.tmux-backups/2026-05-08-pre-redesign/` with `restore.sh`
- Applied per-theme bar redesign (ADR-009):
  - tmux2k cool gradient (lavender → blue → sapphire → teal → green → lavender)
  - catppuccin pastel rainbow pills (mauve session, lavender current window, peach/yellow/pink right segments)
  - ohmytmux warm powerline (rosewater session, peach lock, red battery icon, peach time pill)
- Dropped `fg=` from `window-style`/`window-active-style` in all 3 configs (ADR-008 reversed — ANSI shell colors overrode it anyway)
- Added pane-active-border accent per theme (lavender for tmux2k, mauve for catppuccin)
- Reloaded active theme (tmux2k); catppuccin/ohmytmux pick up on next switch

## Completed (session #6)
- Added per-theme foreground text color via `window-style`/`window-active-style` (subtle fg shift, picked from a 3-option AskUserQuestion):
  - tmux2k: `fg=#bac2de` (catppuccin subtext1, dim cool blue)
  - catppuccin: `fg=#cdd6f4` (catppuccin text, cool white)
  - ohmytmux: `fg=#ffffff` (pure white)
- Reloaded active theme (ohmytmux) via `tmux source-file ~/.tmux.conf` — change applies immediately for ohmytmux; tmux2k/catppuccin pick up on next switch
- Recorded ADR-008

## Completed (session #5)
- User shared desired_catppuccin reference image. Updated catppuccin status-right to match exactly:
  - Branch helper: `git-status.sh` → `git-branch.sh` (drop `✓`/`*` indicator — reverses ADR-002)
  - Battery icon color: green `#a6e3a1` → red `#f38ba8`
  - Time: dropped yellow pill bg + Powerline pill caps; now plain yellow text (`#f9e2af`) on bar bg
- Reloaded active config (tmux2k still active — catppuccin will pick up on next `tmux-switch catppuccin`)

## Completed (session #4)
- Aligned tmux2k segments + colors to match the user-supplied reference image (desired_tmux2k):
  - left-plugins: `"session git"` (CPU/RAM moved off the left)
  - right-plugins: `"cpu ram battery time"` (network removed)
  - session pill: lavender (`"lavender black"`)
  - git pill: green (`"green black"`)
  - cpu / ram: flat green/yellow text on bar bg (`"crust green"`, `"crust yellow"`)
  - battery: green pill (`"green black"`)
  - time: yellow pill (`"yellow black"`)
- Aligned ohmytmux right-side battery segment to the user-supplied reference (desired_ohmytmux):
  - `tmux_conf_theme_colour_16` `#313244` → `#000000` (battery sits on flat black, no gray pill)
- Reloaded active theme via `tmux source-file ~/.tmux.conf`

## Completed (session #3)
- Added `window-style` + `window-active-style` to all three theme configs so pane background paints the theme color (previously only the bar changed; screen used iTerm2 bg)
  - tmux2k: `bg=#11111b`
  - catppuccin: `bg=#1e1e2e`
  - ohmytmux: `bg=#000000`
- Reloaded active config (tmux2k) via `tmux source-file ~/.tmux.conf`

## Completed (session #2)
- Catppuccin: bg `#181825` → `#1e1e2e` (mocha base) for visual distinctness
- Catppuccin: status-right helper `git-branch.sh` → `git-status.sh` (adds `✓`/`*` clean/dirty marker)
- Ohmytmux: `tmux_conf_theme_colour_1` and `colour_15` `#181825` → `#000000` (pure black bar)
- Tmux2k: added `set -g @tmux2k-black "#11111b"` (mocha crust) for distinctness
- All three themes: added `set -g base-index 1` and `setw -g pane-base-index 1` so windows/panes start at 1 (matching reference screenshots)
- Reloaded active theme (tmux2k) via `tmux source-file ~/.tmux.conf`

## Pending (priority order)
1. Verify visual result by switching through all three themes (`tmux-switch` cycles)
2. Optional: add CPU %, RAM %, wifi SSID segments to catppuccin & ohmytmux (user declined this on 2026-05-08; bring up again if user expresses interest)
3. Existing window 0 keeps its old number until killed — user may want to `tmux kill-server` to start fresh and see `1 zsh` style numbering

## Blocked / Known Issues
- `base-index 1` only applies to NEW windows; window 0 stays 0 until tmux-server restart
- AskUserQuestion tool was rejected once at the start of this session — proceed cautiously with multi-question prompts; user prefers concrete proposals to choose from rather than open-ended scoping questions

## Key File Map
| File | Purpose |
|---|---|
| `~/.tmux-switch.sh` | Theme switcher (cycles tmux2k → catppuccin → ohmytmux); managed via `tmux-switch` zsh alias |
| `~/.tmux-theme` | Plain text file, current theme name |
| `~/.tmux.conf` | Symlink to active theme's source conf |
| `~/.tmux/.tmux.conf` | tmux2k source config (bg `#11111b`, base-index 1) |
| `~/.tmux.conf.catppuccin` | Catppuccin source config (bg `#1e1e2e`, base-index 1, git-status.sh) |
| `~/ohmytmux-src/.tmux.conf` | Oh-my-tmux upstream (untouched) |
| `~/.tmux.conf.local.ohmytmux` | Oh-my-tmux local override (bg `#000000`, base-index 1) |
| `~/.tmux/helpers/git-branch.sh` | Prints branch name only |
| `~/.tmux/helpers/git-status.sh` | Prints `branch ✓` (clean) or `branch *` (dirty) |
| `~/.tmux/helpers/battery.sh` | Prints macOS battery `NN%` via pmset |
| `~/tmux-setup-chat.md` | Session #1 conversation record |
| `~/tmux-setup-state.md` | This file |
| `~/tmux-setup-history.md` | Append-only session log |
| `~/tmux-setup-decisions.md` | ADRs |

## Background Color Map (the distinctness rule)
- tmux2k: `#11111b` (mocha crust — nearly black with faint purple)
- catppuccin: `#1e1e2e` (mocha base — purple-tinted)
- ohmytmux: `#000000` (pure black)

## Foreground Text Color Map (Session #6 — REVERSED in Session #7)
ADR-008 attempt was effectively invisible because ANSI shell colors override the tmux default fg. `fg=` was dropped from `window-style`; only `bg=` remains. See ADR-009.

## Theme Temperature Identity (added Session #7, ADR-009)
- **tmux2k** — cool: lavender / blue / sapphire / teal / green
- **catppuccin** — pastel: mauve / lavender / peach / yellow / pink
- **ohmytmux** — warm: rosewater / peach / red / yellow

## Backup & Restore
- Backup dir: `~/.tmux-backups/2026-05-08-pre-redesign/`
- Restore: `bash ~/.tmux-backups/2026-05-08-pre-redesign/restore.sh`
