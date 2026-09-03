# tmux_themes

A switcher for **12 tmux themes**: 4 hand-designed (Signal · Glacier · Atelier · Bauhaus) plus 8 of the most popular open-source themes (Catppuccin, Dracula, Rose Pine, Tokyo Night, tmux-power, tmux-powerline, Gruvbox, Nova).

```
tmux-switch              # cycle next theme
tmux-switch prev         # cycle backward
tmux-switch list         # interactive fzf picker
tmux-switch <name>       # jump straight to a theme
```

---

## The 12 themes

| name | identity | source |
| --- | --- | --- |
| `signal` | quiet minimal · three colours, and colour only where something needs attention | hand-designed |
| `glacier` | cool cascading powerline · lavender → sapphire → green | redesigned tmux2k |
| `atelier` | pastel floating pills · 6 pastel colors with rounded ends | redesigned catppuccin |
| `bauhaus` | warm brutalist plates · heavy session frame + outlined data plates | redesigned ohmytmux |
| `catppuccin-mocha` | pastel rounded modules | [catppuccin/tmux](https://github.com/catppuccin/tmux) |
| `dracula` | purple/pink powerline | [dracula/tmux](https://github.com/dracula/tmux) |
| `rose-pine` | muted minimalist · moon variant | [rose-pine/tmux](https://github.com/rose-pine/tmux) |
| `tokyo-night` | dark navy with neon accents | [janoamaral/tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux) |
| `tmux-power` | bold heavy powerline · gold variant | [wfxr/tmux-power](https://github.com/wfxr/tmux-power) |
| `powerline-classic` | original heavy powerline | [erikw/tmux-powerline](https://github.com/erikw/tmux-powerline) |
| `gruvbox` | warm retro flat segments | [egel/tmux-gruvbox](https://github.com/egel/tmux-gruvbox) |
| `nova` | clean rectangular blocks · nord-style | [o0th/tmux-nova](https://github.com/o0th/tmux-nova) |

Glacier · Atelier · Bauhaus each pick a different **structural pattern**: cascade, floating beads, brutalist plates. They're not just three palettes of the same shape — see `docs/mockups/` for the design exploration that led to them.

---

## Install

On a brand-new machine, one command:

```sh
curl -fsSL https://raw.githubusercontent.com/morecodinguz/tmux_themes/main/install.sh | bash
```

That clones the repo to `~/tmux_themes`, installs anything missing, links everything up, and leaves you on the `signal` theme. It is safe to re-run.

Options:

```sh
... | bash -s -- --minimal        # skip the 13 upstream plugin repos
... | bash -s -- --theme glacier  # start on a different theme
... | bash -s -- --no-shell       # do not touch ~/.zshrc
```

`--minimal` is enough for the four hand-written themes (`signal`, `glacier`, `atelier`, `bauhaus`) and `powerline-classic`; the eight famous themes need their upstream plugins.

The installer:

1. Clones the repo to `~/tmux_themes` (or updates it if already there). The theme files reference that exact path, so if you cloned elsewhere it symlinks `~/tmux_themes` to your clone.
2. Installs `tmux` if missing, plus `fzf` and `zoxide`, via Homebrew. Stops with instructions if Homebrew is not installed.
3. Clones the 13 upstream plugin repos into `~/.tmux/plugins/` unless `--minimal`.
4. Backs up an existing real `~/.tmux.conf` before replacing it with a symlink.
5. Adds a hook to `~/.zshrc` between `# >>> tmux_themes >>>` markers — re-running replaces the block instead of stacking copies.
6. Verifies the symlinks resolve and the tmux config actually parses, on a throwaway socket so a running tmux server is never touched.

Requirements: `git`, and a Nerd Font in your terminal (e.g. JetBrainsMono Nerd Font Mono) for the famous themes' glyphs. `signal` uses no glyphs and works in any font.

---

## Per-theme shell colors (optional)

Switching the tmux bar isn't the whole story — the **shell** can change colors too. If you use **zsh + Powerlevel10k + zsh-syntax-highlighting + zsh-autosuggestions**, the switcher will also re-color:

- Powerlevel10k prompt segments (path, git branch, time, prompt char)
- zsh-syntax-highlighting tokens (commands, paths, strings, options, comments, errors)
- zsh-autosuggestions ghost text
- `ls` output via `LS_COLORS` (requires GNU `ls`, i.e. `gls` from Homebrew coreutils)

Add the integration block from `install.sh` to your `~/.zshrc`. Then every `tmux-switch` swap re-sources `~/.shell-theme.zsh` and reloads p10k — your prompt, typed commands, and `ls` output all change live in the current shell.

## Themed Claude Code statusline (optional)

If you use [Claude Code](https://claude.com/claude-code) the repo includes `claude-statusline.sh`, a small script that renders this beneath your Claude session:

```
 ~/tmux_themes  ·   main  ·   Opus 4.7  ·  ▰▰▰▰▱▱▱▱▱▱ 43%
```

Colors come from your active tmux theme via `~/.tmux-theme`, so the Claude statusline retunes itself whenever you `tmux-switch`. To enable, point Claude Code's `statusLine.command` setting at the script:

```jsonc
// ~/.claude/settings.json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/tmux_themes/claude-statusline.sh"
  }
}
```

## Layout

```
tmux_themes/
├── tmux-switch.sh         # the switcher
├── install.sh             # one-shot bootstrap
├── claude-statusline.sh   # Claude Code statusline (themed)
├── themes/
│   ├── _common.tmux       # shared options + key bindings
│   ├── _meta.tsv          # theme name → description (drives picker)
│   └── *.tmux.conf        # 11 theme configs
├── shell/                 # 11 per-theme zsh color packs
│   └── *.zsh              # p10k overrides + syntax highlighting + LS_COLORS
├── helpers/
│   ├── cpu.sh, mem.sh
│   ├── battery.sh
│   ├── git-branch.sh, git-status.sh
│   └── path-short.sh
└── docs/
    ├── tmux-setup-*.md    # design history
    └── mockups/           # HTML mockups from the design process
```

---

## How switching works

The switcher symlinks `~/.tmux.conf` to whichever theme conf is active and runs `tmux source-file ~/.tmux.conf` against the running server. The current theme name is persisted in `~/.tmux-theme`.

Note: when switching between **plugin-based** themes (Dracula, Rose Pine, etc.) the previous plugin's hooks may leave visual artifacts. Cure: `tmux kill-server` and reattach. The switcher prints this tip after every switch.

---

## Roll back

To remove tmux_themes and revert your shell to whatever you had before:

```sh
rm ~/.tmux-switch.sh                    # remove the symlink
mv ~/.tmux-switch.sh.bak.* ~/.tmux-switch.sh   # if you had one
rm -rf ~/tmux_themes                    # remove the repo
```

The plugin clones in `~/.tmux/plugins/` are safe to keep or delete as you wish.

---

## Terminal colours

`iterm/signal.itermcolors` is a dark iTerm2 preset matching the `signal` theme.
Import it with **iTerm2 → Settings → Profiles → Colors → Color Presets… →
Import…**, then pick `signal` from the same dropdown.

It matters more than it sounds: tmux paints panes black, so a profile still
carrying a light-background palette leaves bold text, the cursor and ANSI blue
almost unreadable inside tmux.
