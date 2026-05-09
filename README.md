# tmux_themes

A switcher for **11 tmux themes**: 3 hand-designed (Glacier · Atelier · Bauhaus) plus 8 of the most popular open-source themes (Catppuccin, Dracula, Rose Pine, Tokyo Night, tmux-power, tmux-powerline, Gruvbox, Nova).

```
tmux-switch              # cycle next theme
tmux-switch prev         # cycle backward
tmux-switch list         # interactive fzf picker
tmux-switch <name>       # jump straight to a theme
```

---

## The 11 themes

| name | identity | source |
| --- | --- | --- |
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

Requirements: tmux, git, a Nerd Font in your terminal (e.g. JetBrainsMono Nerd Font Mono). `fzf` is optional but recommended.

```sh
git clone https://github.com/morecodinguz/tmux_themes ~/tmux_themes
bash ~/tmux_themes/install.sh
```

The installer:

1. Verifies tmux/fzf are installed (offers `brew install fzf` if missing)
2. Clones the 9 plugin repos used by the famous themes into `~/.tmux/plugins/`
3. Symlinks `~/.tmux-switch.sh` → `~/tmux_themes/tmux-switch.sh`
4. Sets the default theme to `atelier`

Add to your shell rc (`~/.zshrc` or `~/.bashrc`):

```sh
alias tmux-switch='~/.tmux-switch.sh'
```

Then in any shell:

```sh
tmux-switch list      # opens fzf picker
```

---

## Per-theme shell colors (optional)

Switching the tmux bar isn't the whole story — the **shell** can change colors too. If you use **zsh + Powerlevel10k + zsh-syntax-highlighting + zsh-autosuggestions**, the switcher will also re-color:

- Powerlevel10k prompt segments (path, git branch, time, prompt char)
- zsh-syntax-highlighting tokens (commands, paths, strings, options, comments, errors)
- zsh-autosuggestions ghost text
- `ls` output via `LS_COLORS` (requires GNU `ls`, i.e. `gls` from Homebrew coreutils)

Add the integration block from `install.sh` to your `~/.zshrc`. Then every `tmux-switch` swap re-sources `~/.shell-theme.zsh` and reloads p10k — your prompt, typed commands, and `ls` output all change live in the current shell.

## Layout

```
tmux_themes/
├── tmux-switch.sh         # the switcher
├── install.sh             # one-shot bootstrap
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
