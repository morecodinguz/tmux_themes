# Tmux Setup — Session History (append-only)

## Session #7 — 2026-05-08
### What was done
- User asked for all 3 themes to "look good and well designed and organized with colors matching their own background" and noted the bottom bars don't look cool. Also asked whether pane text colors are the same across all 3.
- Clarified that the Session #6 `window-style fg=` shift is invisible in practice — ANSI shell colors (Powerlevel10k prompt, ls, syntax highlighting) override the tmux default fg, so almost no rendered text uses it.
- Backed up all 4 config files to `~/.tmux-backups/2026-05-08-pre-redesign/` (tmux2k, catppuccin, ohmytmux.local, tmux-switch.sh) and added `restore.sh` for one-command rollback.
- Applied per-theme bar redesigns (ADR-009):
  - **tmux2k** (`#11111b`) — "Cool gradient sweep": session=lavender, git=blue, cpu=crust+sapphire, ram=crust+teal, battery=green pill, time=lavender pill. Added `pane-active-border-style fg=#b4befe` (lavender).
  - **catppuccin** (`#1e1e2e`) — "Pastel rainbow pills": session=mauve pill, current window=lavender pill (kept as focal), git=peach pill, battery=yellow pill (battery glyph inside, dark text), time=pink pill. Pane-active-border updated mauve to match session pill. message-style updated mauve.
  - **ohmytmux** (`#000000`) — "Stark warm powerline": colour_4 teal→rosewater, colour_9 yellow→peach, colour_10 teal→rosewater, colour_11 green→red, colour_17 yellow→peach. Battery icon hex `#a6e3a1` (green) → `#f38ba8` (red).
- Dropped `fg=` from `window-style`/`window-active-style` in all 3 configs (Session #6 ADR-008 effectively reversed — kept `bg=` for pane bg distinctness).
- Reloaded active config (tmux2k currently active). catppuccin/ohmytmux pick up on next switch.

### Decisions made
- Reverted ADR-008's fg trick because it didn't have visible effect under any normal shell. Documented in ADR-009.
- Each theme gets a temperature identity: tmux2k=cool, catppuccin=pastel, ohmytmux=warm. Drifted from README references (ADR-006/007 era) per user's redesign brief.
- Used Python rewrite for catppuccin status-right (Nerd Font battery glyph U+F240 was being stripped on Write; restored after).
- Backup directory pattern: `~/.tmux-backups/<YYYY-MM-DD>-<reason>/` with a `restore.sh` per backup.

### What's next
- User to `tmux-switch catppuccin` and `tmux-switch ohmytmux` to visually verify the new bars.
- If a theme feels too cold/warm/pastel, swap individual segment colors — palette is in each config's comment.
- If user wants to roll back: `bash ~/.tmux-backups/2026-05-08-pre-redesign/restore.sh`.

### Files changed
- `~/.tmux/.tmux.conf` (segment colors, window-style, pane-border)
- `~/.tmux.conf.catppuccin` (rewrite — pastel pills, mauve session, peach git, yellow battery, pink time)
- `~/.tmux.conf.local.ohmytmux` (palette colour_4/9/10/11/17, battery icon hex, window-style)
- `~/.tmux-backups/2026-05-08-pre-redesign/` (new — all 4 backups + restore.sh)
- `~/tmux-setup-state.md`, `~/tmux-setup-history.md`, `~/tmux-setup-decisions.md` (this entry + ADR-009)

---

## Session #6 — 2026-05-08
### What was done
- User shared the same 3 reference images (catppuccin, ohmytmux, tmux2k) and asked for distinctness across not just bars/bg but text color too
- Presented 3 options via AskUserQuestion (subtle fg shift / bold hue tint / inactive-only tint); user chose "subtle fg shift"
- Edited the `window-style` + `window-active-style` lines in all three configs to add `fg=`:
  - `~/.tmux/.tmux.conf` → `fg=#bac2de` (catppuccin subtext1)
  - `~/.tmux.conf.catppuccin` → `fg=#cdd6f4` (catppuccin text)
  - `~/.tmux.conf.local.ohmytmux` → `fg=#ffffff` (pure white)
- Reloaded active config (ohmytmux currently active)
- Added ADR-008 and a new "Foreground Text Color Map" section in state.md mirroring the bg map

### Decisions made
- Chose subtle fg shift over bold hue tint to avoid weirdness in ls/syntax colors. Bold tint (e.g. green for tmux2k) would have green-shifted every line including ANSI-colored output.
- Kept fg the same for active and inactive panes — user didn't ask for split-pane differentiation. The "inactive-only" option was offered as a third path but skipped.
- Color picks all stay within catppuccin palette except ohmytmux's pure white (which matches its "raw black canvas" identity)

### What's next
- User to `tmux-switch tmux2k` and `tmux-switch catppuccin` to visually verify the subtle text-color shift across all three themes
- If tmux2k's `#bac2de` reads as too dim, escalate to `#cdd6f4`
- If user wants stronger differentiation, switch to bold hue tint (Option B from the question)

### Files changed
- `~/.tmux/.tmux.conf` (window-style fg added)
- `~/.tmux.conf.catppuccin` (window-style fg added)
- `~/.tmux.conf.local.ohmytmux` (window-style fg added)
- `~/tmux-setup-state.md`, `~/tmux-setup-history.md`, `~/tmux-setup-decisions.md` (this entry + ADR-008)

---

## Session #5 — 2026-05-08
### What was done
- User shared a third reference image (desired_catppuccin) showing: lavender `seah-claude` pill, lavender `1 zsh` current-window pill, dim `2 nvim`, plain `main` (no checkmark), red battery icon + `94%`, plain yellow `10:59` (no pill)
- Updated `~/.tmux.conf.catppuccin` status-right line:
  - swapped `git-status.sh` for `git-branch.sh` (no `✓`/`*` clean/dirty marker)
  - battery icon color hex `#a6e3a1` → `#f38ba8`
  - removed Powerline pill caps (U+E0B6 / U+E0B4) and yellow bg around time; left plain yellow text (`#f9e2af`) on bar bg
- Used a Python rewrite (not Edit) because the line contained Nerd Font glyphs that didn't round-trip cleanly through the Edit tool's string match
- Reloaded active config (tmux2k currently active; catppuccin changes apply on next switch)
- Recorded ADR-007 superseding ADR-002 (the prior reference image had `✓`, the new one doesn't)

### Decisions made
- Reversed ADR-002. The earlier README screenshot showed `main ✓`; the user's actual desired reference image shows just `main`. The user's reference wins.
- Battery icon set to red `#f38ba8` (catppuccin red). Matches the warm-tinted icon in the reference; could also be maroon `#eba0ac` if the user wants softer.
- Time kept yellow (`#f9e2af`) but as text rather than pill. The reference shows `10:59` slightly warmer than surrounding white text — yellow plain-text matches that without re-introducing the pill.

### What's next
- User to `tmux-switch catppuccin` and visually verify against the reference
- If battery icon hue feels too red, swap to maroon `#eba0ac` (one-line edit)
- If time should be white instead of yellow, swap fg to `#cdd6f4`

### Files changed
- `~/.tmux.conf.catppuccin` (status-right line + comment)
- `~/tmux-setup-state.md`, `~/tmux-setup-history.md`, `~/tmux-setup-decisions.md` (this entry + ADR-007)

---

## Session #4 — 2026-05-08
### What was done
- User shared two reference images (desired_ohmytmux + desired_tmux2k) and asked for the configs to match them exactly
- tmux2k changes (`~/.tmux/.tmux.conf`):
  - moved `cpu ram` from left-plugins to right-plugins
  - removed `network` from right-plugins
  - recolored: session→lavender, git→green, battery→green pill, time→yellow pill, cpu/ram→flat green/yellow text on bar bg using catppuccin `crust` as bg
- ohmytmux change (`~/.tmux.conf.local.ohmytmux`):
  - `tmux_conf_theme_colour_16` `#313244` → `#000000` so the battery segment matches the bar bg in the reference (flat black, not gray pill)
- Reloaded active theme via `tmux source-file ~/.tmux.conf`

### Decisions made
- For tmux2k, mapped CPU/RAM to "flat" segments by setting their bg to catppuccin `crust` (same as @tmux2k-black `#11111b`). The reference shows them as colored text without distinct pill backgrounds.
- Did NOT modify catppuccin theme — user only supplied references for ohmytmux and tmux2k. Image #4 and Image #5 were duplicates of the same ohmytmux reference.

### What's next
- User to visually verify both themes against the reference images by `tmux-switch tmux2k` and `tmux-switch ohmytmux`
- If tmux2k color names `lavender` or `crust` don't resolve in the installed tmux2k version, fall back to hex values via custom segment definitions
- If catppuccin theme also needs a reference-image update, user to share it

### Files changed
- `~/.tmux/.tmux.conf` (left-plugins, right-plugins, all segment colors)
- `~/.tmux.conf.local.ohmytmux` (colour_16)
- `~/tmux-setup-state.md`, `~/tmux-setup-history.md`, `~/tmux-setup-decisions.md` (this entry)

---

## Session #3 — 2026-05-08
### What was done
- User reported that switching themes only changed the status bar — the screen (pane content area) kept iTerm2's background regardless of active theme
- Root cause: none of the three theme configs set `window-style`/`window-active-style`, so tmux let the terminal emulator's bg show through
- Added `set -g window-style 'bg=<color>'` + `set -g window-active-style 'bg=<color>'` to each config:
  - `~/.tmux/.tmux.conf` → `#11111b` (mocha crust, matches @tmux2k-black)
  - `~/.tmux.conf.catppuccin` → `#1e1e2e` (mocha base, matches status-style bg)
  - `~/.tmux.conf.local.ohmytmux` → `#000000` (pure black, matches colour_1)
- Reloaded active theme via `tmux source-file ~/.tmux.conf`

### Decisions made
- Picked tmux-only `window-style` over switching iTerm2 profiles. Trade-off: the very edge of the iTerm2 window (outside tmux's painted area) still shows iTerm2's bg, but no iTerm2 profile setup is needed and pane contents fully repaint per theme.
- Bg color per theme matches the existing bar bg distinctness scheme (no new palette).

### What's next
- User to visually verify all three themes now show different pane backgrounds, not just bars
- Optional follow-up: add iTerm2 profile switching to `tmux-switch.sh` for full edge-to-edge bg change (would require creating 3 iTerm2 profiles first)

### Files changed
- `~/.tmux/.tmux.conf` (added window-style block after base-index)
- `~/.tmux.conf.catppuccin` (added window-style block after base-index)
- `~/.tmux.conf.local.ohmytmux` (added window-style block in user-overrides section, ~line 528)
- `~/tmux-setup-state.md`, `~/tmux-setup-history.md`, `~/tmux-setup-decisions.md` (this entry)

---

## Session #2 — 2026-05-08
### What was done
- Compared user's current screenshots (catppuccin, ohmytmux, tmux2k) to desired reference images (catppuccin/tmux README + gpakosz/.tmux README)
- Identified the structural gaps were minimal: catppuccin lacked the `✓`/`*` clean/dirty branch indicator; both themes numbered windows from 0 instead of 1
- Switched catppuccin status-right helper from `git-branch.sh` to `git-status.sh`
- Set three distinct status-bar backgrounds across the themes (user explicitly asked for distinctness):
  - tmux2k: `#11111b` (catppuccin mocha crust) via `@tmux2k-black` plugin var
  - catppuccin: `#1e1e2e` (mocha base) — replaced all `#181825` references
  - ohmytmux: `#000000` (pure black) — `colour_1` and `colour_15` updated
- Added `set -g base-index 1` and `setw -g pane-base-index 1` to all three theme configs
- Reloaded active config via `tmux source-file ~/.tmux.conf`

### Decisions made
- Did NOT add CPU/RAM/wifi segments to catppuccin and ohmytmux. User clarified they wanted the themes to match their respective project README screenshots, which only show session/window/branch/battery/time. tmux2k already had those richer segments via plugin.
- Kept each theme's own visual style (catppuccin pills, ohmytmux powerline notches) — only changed bg color, not segment shapes.
- User picked `#11111b` (mocha crust) for tmux2k from a 3-option AskUserQuestion (chose option 1).

### What's next
- User to visually verify by cycling `tmux-switch` through all three themes
- Run `tmux kill-server` (then re-attach) if they want existing windows renumbered from 1
- If user later wants more data density on catppuccin/ohmytmux: add CPU/RAM/wifi helpers (mirrors tmux2k segments)

### Files changed
- `~/.tmux.conf.catppuccin` (modified): bg color, git-status.sh, base-index
- `~/.tmux.conf.local.ohmytmux` (modified): colour_1, colour_15, base-index in user-overrides section
- `~/.tmux/.tmux.conf` (modified): @tmux2k-black, base-index
- `~/tmux-setup-state.md` (new)
- `~/tmux-setup-history.md` (new)
- `~/tmux-setup-decisions.md` (new)

---
