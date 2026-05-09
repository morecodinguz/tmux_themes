# Tmux Setup — Architectural Decisions (ADR)

## ADR-009: Per-theme temperature identity (cool / pastel / warm) — 2026-05-08
**Context:** User asked for all 3 themes to look "well designed and organized with colors matching their own background." Prior bars (post-ADR-006/007) faithfully matched README references but felt mismatched and uncool when viewed as a set. User also noticed pane text colors looked identical across themes — true in practice because ANSI shell colors override the `window-style fg=` set in ADR-008.
**Options:**
- Keep matching READMEs (status quo, but user is dissatisfied)
- Single unifying palette across all 3 themes (consistency, no per-theme identity)
- Per-theme **temperature** identity: each theme picks a half of the catppuccin palette that matches its bg darkness/warmth
**Decision:** Per-theme temperature identity.
- **tmux2k** (`#11111b`, near-black-purple) → **cool**: lavender / blue / sapphire / teal / green
- **catppuccin** (`#1e1e2e`, purple base) → **pastel**: mauve / lavender / peach / yellow / pink
- **ohmytmux** (`#000000`, pure black) → **warm**: rosewater / peach / red / yellow
**Reason:** Each bg has a different "color temperature" (cool/neutral/black). Pairing each with palette tones in the same temperature makes the bar feel like an extension of the bg, not a sticker on top. Also gives each theme a distinct emotional flavor at a glance, beyond just bg luminance. Supersedes the README-faithful era of ADR-006/007 — references were the seed, but the project has matured past them. Pane text fg setting from ADR-008 was effectively reversed (kept `bg=` only).

## ADR-008: Per-theme foreground text color via window-style — 2026-05-08 [SUPERSEDED by ADR-009]
**Context:** ADR-001 made backgrounds distinct, but pane text fg was identical across themes (terminal default). User asked for text-color distinctness too, sharing the same 3 reference images.
**Options:**
- Subtle fg shift within catppuccin palette (cool dim blue / cool white / pure white) — small change, no syntax-color side effects
- Bold hue tint (green / rosewater / white) — strong personality but tints every line including ANSI command output, can clash with ls colors
- Active-pane keeps default, inactive-pane gets tint — clean separation but only visible when split
**Decision:** Subtle fg shift. tmux2k=`#bac2de` (subtext1), catppuccin=`#cdd6f4` (text), ohmytmux=`#ffffff`.
**Reason:** Distinctness without breaking syntax-colored output. Active+inactive get the same fg so the effect is visible immediately on entering each theme, not dependent on splits. Stays in the catppuccin palette except ohmytmux which goes pure white to match its black-canvas identity.

## ADR-007: Catppuccin matches user's actual reference image, supersedes ADR-002 — 2026-05-08
**Context:** ADR-002 picked `git-status.sh` (`main ✓`) based on the catppuccin/tmux GitHub README screenshot. In Session #5, user supplied their own reference image (desired_catppuccin) which shows plain `main` (no `✓`), a red/pink battery icon (not green), and plain yellow time text (no yellow pill).
**Options:**
- Keep ADR-002 design (README-faithful)
- Match the user's reference verbatim (supersede ADR-002)
- Make it configurable
**Decision:** Match the user's reference verbatim.
**Reason:** "Reference image" in this project means whatever the user has specifically shown. The README is one possible reference; the user's screenshot is the authoritative one. ADR-002 is now superseded — the helper choice (`git-branch.sh`), battery color (`#f38ba8`), and time styling (yellow text, no pill) all changed.

## ADR-006: Match each theme's status bar exactly to its reference image — 2026-05-08
**Context:** User supplied reference images (desired_ohmytmux, desired_tmux2k) and asked for "exactly like them including everything such as colors, their orders." Prior bars were in a similar palette but didn't match segment ordering or specific colors.
**Options:**
- Approximate the references with closest catppuccin-named tokens
- Hardcode hex values everywhere for pixel match
- Hybrid: catppuccin token names where available, hex fallback only when needed
**Decision:** Hybrid. tmux2k uses catppuccin color names (`lavender`, `green`, `yellow`, `crust`) since its plugin resolves them from the active palette. ohmytmux already uses hex via `tmux_conf_theme_colour_*`, so kept hex.
**Reason:** Color names stay in sync with the catppuccin palette if it ever updates; hex is only used where the framework requires it (gpakosz). For tmux2k, "flat" segments (CPU, RAM) use `crust` as bg to blend with `@tmux2k-black="#11111b"` — same value, but lets the framework apply its own powerline math.

## ADR-005: Use tmux window-style for per-theme screen bg, not iTerm2 profiles — 2026-05-08
**Context:** User noted that switching themes only changed the status bar; the screen (pane content area) stayed on iTerm2's default bg. Theme distinctness was therefore only visible in the bottom strip.
**Options:**
- Tmux `window-style`/`window-active-style` only — paints pane bg per theme, no iTerm2 changes
- Switch iTerm2 profiles via `tmux-switch.sh` (escape sequence) — requires creating 3 iTerm2 profiles in advance
- Both approaches combined
**Decision:** Tmux `window-style` only.
**Reason:** Zero external setup, lives entirely in the theme configs, reloads instantly with `tmux source-file`. Trade-off is that iTerm2's true bg still shows at the very window edges, but pane contents (where the user is actually looking) fully repaint per theme. If edge-to-edge change is wanted later, layer iTerm2 profile switching on top.

## ADR-001: Distinct status-bar backgrounds per theme — 2026-05-08
**Context:** All three themes (tmux2k default, catppuccin, ohmytmux) were rendering with effectively the same dark bg (`#181825` or `#1e2030`), making it hard to tell at a glance which theme was active.
**Options:**
- Keep all dark/identical (status quo)
- Pick three clearly different shades within the catppuccin family
- Use unrelated palettes (e.g., solarized for one, gruvbox for another)
**Decision:** Three shades, two within catppuccin family + pure black.
- tmux2k: `#11111b` (mocha crust)
- catppuccin: `#1e1e2e` (mocha base)
- ohmytmux: `#000000` (pure black)
**Reason:** Distinctness without breaking the visual coherence of the catppuccin pill/powerline accents already in use. Pure black for ohmytmux gives a strong contrast that matches the gpakosz README screenshots.

## ADR-002: Catppuccin uses git-status.sh, not git-branch.sh — 2026-05-08 [SUPERSEDED by ADR-007]
**Context:** The reference catppuccin/tmux README screenshot shows `main ✓` (branch + clean indicator). User's bar showed only the branch name.
**Options:**
- Stick with git-branch.sh (branch name only)
- Switch to git-status.sh (already exists in `~/.tmux/helpers/`, prints `✓` clean or `*` dirty)
- Build a new helper from scratch
**Decision:** Switch to existing git-status.sh.
**Reason:** Matches reference design; helper already written and tested; no new code needed.

## ADR-003: Window/pane indices start at 1 across all themes — 2026-05-08
**Context:** Reference screenshots from both catppuccin and gpakosz READMEs show `1 zsh`, `2 nvim`. tmux defaults to 0-indexed which made the user's bars show `0 zsh`.
**Options:**
- Apply only to catppuccin/ohmytmux (where user noticed it)
- Apply globally across all three themes for consistency
**Decision:** Apply to all three theme configs.
**Reason:** Switching themes shouldn't shuffle window numbers. Each theme's source conf is loaded fresh on switch, so the setting must be in each. Cost is one line per file.

## ADR-004: Did NOT add CPU/RAM/wifi segments to catppuccin & ohmytmux — 2026-05-08
**Context:** tmux2k shows CPU %, RAM %, wifi SSID. Catppuccin and ohmytmux do not. User initially said "other 2 look incomplete," which suggested they wanted parity.
**Options:**
- Full parity — add stat segments to all themes
- Match each theme's own reference design (catppuccin/tmux README, gpakosz README)
- Add only stats, skip layout changes
**Decision:** Match each theme's own reference design. No new segments added.
**Reason:** User clarified by sharing the README screenshots — those don't include CPU/RAM/wifi. Each theme has a distinct identity; tmux2k = data density, catppuccin/ohmytmux = clean minimal pills. Adding stats would fight that identity.
