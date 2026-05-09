# Tmux setup conversation — session record

Date: 2026-05-08
Goal: Fix tmux bottom bar showing `?` icons; build a 3-theme switcher (tmux2k, catppuccin, ohmytmux); make the catppuccin and ohmytmux bars match reference designs.

---

## 1. Original problem

Bottom tmux bar showed `?` boxes instead of icons. Cause: iTerm2 was using **MesloLGS NF** (the Powerlevel10k variant), which only ships a small subset of Nerd Font glyphs. tmux2k's cpu/ram/battery/network icons weren't included.

**Fix**: changed iTerm2 → Profiles → Text → Font to **JetBrainsMono Nerd Font Mono** (Regular). Already installed at `~/Library/Fonts/JetBrainsMonoNerdFontMono-Regular.ttf`.

Result: icons render correctly. Use this font going forward; it has powerline + full Nerd Font icons.

---

## 2. Three configs in play

| File | Plugin/system | Notes |
|---|---|---|
| `~/.tmux/.tmux.conf` | tmux2k plugin | catppuccin palette via @tmux2k-theme, icons-only |
| `~/.tmux.conf.catppuccin` | catppuccin plugin (sourced for window-status only) | Hand-styled bar |
| `~/ohmytmux-src/.tmux.conf` + `~/.tmux.conf.local.ohmytmux` | gpakosz/.tmux | Powerline pills with catppuccin colors |

The old `~/.tmux-switch.sh` was buggy (overwrote `~/.tmux/.tmux.conf` with oh-my-tmux content on second toggle, destroying the tmux2k config) and only handled two themes.

---

## 3. New `~/.tmux-switch.sh`

Symlink-based, three themes, never overwrites source configs.

```bash
tmux-switch              # cycle: tmux2k → catppuccin → ohmytmux → tmux2k
tmux-switch tmux2k       # jump to specific
tmux-switch catppuccin
tmux-switch ohmytmux
tmux-switch list         # show available + current
```

State is tracked in `~/.tmux-theme`. After switching, the script runs `tmux source-file` if a server is running. For a fully clean reload (kills lingering plugin processes), use `tmux kill-server` and restart.

---

## 4. Helper scripts (`~/.tmux/helpers/`)

- **`git-branch.sh`** — prints current pane's git branch, or empty
- **`git-status.sh`** — prints `branch ✓` if clean, `branch *` if dirty, empty if not a repo
- **`battery.sh`** — prints `94%` (macOS, via `pmset`)

All use `tmux display-message -p '#{pane_current_path}'` to get the active pane's directory.

---

## 5. Catppuccin config — `~/.tmux.conf.catppuccin`

Hand-crafted (no `@catppuccin_status_*` modules) to match reference exactly.

- **Left**: lavender (`#b4befe`) session pill with rounded ends (`` `` glyphs)
- **Window list**: current = lavender pill, inactive = `#6c7086` gray
- **Right**: git branch (white) · green battery icon `` + percent · yellow time pill `HH:MM`
- **Bar bg**: `#181825` (mantle)

Keybindings: prefix C-a, vi mode, mouse, `|`/`-` splits, `hjkl` resize, `m` zoom.

---

## 6. Ohmytmux config — `~/.tmux.conf.local.ohmytmux`

Customized via ohmytmux's variable system (does NOT load the catppuccin plugin — that was a conflict).

- **Color palette** (lines 89–105): catppuccin mocha mapped to colour_1 through colour_17
- **status_left** (line 272): `  #S ` (lock + session, single teal segment using colour_4/_9)
- **status_right** (line 274): three powerline segments
  1. `#(~/.tmux/helpers/git-status.sh)` — branch + ✓/* indicator
  2. ` #{?battery_percentage,...}` — green battery icon + percent
  3. `%H:%M` — yellow time pill (colour_17 bg)
- **User keybindings** at bottom of file (replacing the old catppuccin plugin invocation): prefix C-a, splits, resize, vi mode, mouse

---

## 7. Test path after kill-server

```bash
tmux kill-server          # wipe leftover plugin state
tmux-switch ohmytmux      # or tmux2k / catppuccin
tmux                      # fresh start
```

If anything visual is off, see the troubleshooting notes below.

---

## 8. Open / pending items

- **Verify both configs render exactly like the reference images** after a clean kill-server restart. The user noted the catppuccin output didn't match initially — that was due to plugin pollution from rapid `tmux-switch` calls without restart, plus the prior catppuccin config relied on `@catppuccin_status_session` which doesn't produce the lavender pill in the reference. The new manual styling should match.
- **Window name auto-rename** — tmux defaults can rename windows to hostname (e.g. `Daniels-MacBook-Pro.local`). If unwanted, add `set -g allow-rename off` and `setw -g automatic-rename off`.
- **Battery `--`** — if ohmytmux's `#{battery_percentage}` doesn't populate, may need to verify `tmux_conf_battery_*` settings or fall back to calling `~/.tmux/helpers/battery.sh`.

---

## 9. Files modified / created

```
~/.tmux-switch.sh                       (rewrote — 3-theme cycling)
~/.tmux.conf.catppuccin                 (rewrote — hand-styled)
~/.tmux.conf.local.ohmytmux             (palette + status templates + bindings)
~/.tmux/helpers/git-branch.sh           (new)
~/.tmux/helpers/git-status.sh           (new)
~/.tmux/helpers/battery.sh              (new)
~/tmux-setup-chat.md                    (this file)
```

Untouched (source configs preserved):
```
~/.tmux/.tmux.conf                      (tmux2k config — same as before)
~/ohmytmux-src/.tmux.conf               (oh-my-tmux upstream)
```

iTerm2 setting (manual change, not a file): Profiles → Text → Font = `JetBrainsMono Nerd Font Mono` Regular.
