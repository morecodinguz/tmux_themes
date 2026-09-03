#!/usr/bin/env bash
# Install tmux_themes on a fresh machine.
#
#   One command, nothing cloned first:
#     curl -fsSL https://raw.githubusercontent.com/morecodinguz/tmux_themes/main/install.sh | bash
#
#   Or from inside an existing clone:
#     bash install.sh
#
# Flags:
#   --minimal      skip the 13 upstream plugin repos. The hand-written themes
#                  (signal, glacier, atelier, bauhaus, powerline-classic) need
#                  no plugins; only the 8 famous ones do.
#   --theme NAME   which theme to start on (default: signal)
#   --no-shell     do not touch ~/.zshrc
#
# Idempotent: safe to re-run.

set -euo pipefail

REPO_URL="https://github.com/morecodinguz/tmux_themes"
PLUGINS_DIR="$HOME/.tmux/plugins"
DEFAULT_THEME="signal"
DO_PLUGINS=1
DO_SHELL=1

while [[ $# -gt 0 ]]; do
    case "$1" in
        --minimal)  DO_PLUGINS=0; shift ;;
        --no-shell) DO_SHELL=0; shift ;;
        --theme)    DEFAULT_THEME="${2:?--theme needs a name}"; shift 2 ;;
        -h|--help)  sed -n '2,20p' "$0" 2>/dev/null || echo "see $REPO_URL"; exit 0 ;;
        *)          echo "unknown flag: $1" >&2; exit 1 ;;
    esac
done

say()  { printf '\033[1;35m▸\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ─── 0. Find or fetch the repo ──────────────────────────────────────────
# Works both when run as a file and when piped from curl (no file on disk).
REPO_DIR=""
SRC="${BASH_SOURCE[0]:-}"
if [[ -n "$SRC" && -f "$SRC" ]]; then
    REPO_DIR="$(cd "$(dirname "$SRC")" && pwd)"
fi

if [[ -z "$REPO_DIR" || ! -d "$REPO_DIR/themes" ]]; then
    REPO_DIR="$HOME/tmux_themes"
    have git || die "git is required. On macOS: xcode-select --install"
    if [[ -d "$REPO_DIR/.git" ]]; then
        say "Updating existing clone at $REPO_DIR"
        git -C "$REPO_DIR" pull --ff-only --quiet || warn "could not fast-forward; keeping what is there"
    else
        say "Cloning $REPO_URL into $REPO_DIR"
        git clone --quiet "$REPO_URL" "$REPO_DIR" || die "clone failed"
    fi
fi
ok "repo: $REPO_DIR"

# Every theme conf refers to helpers as ~/tmux_themes/... , so that path has to
# resolve no matter where the repo was actually cloned.
if [[ "$REPO_DIR" != "$HOME/tmux_themes" ]]; then
    if [[ -e "$HOME/tmux_themes" && ! -L "$HOME/tmux_themes" ]]; then
        die "$HOME/tmux_themes already exists and is not a symlink.
   The themes reference that exact path. Move it aside and re-run."
    fi
    ln -sfn "$REPO_DIR" "$HOME/tmux_themes"
    ok "~/tmux_themes -> $REPO_DIR"
fi

# ─── 1. Dependencies ────────────────────────────────────────────────────
say "Checking dependencies"

if ! have tmux; then
    if have brew; then
        say "Installing tmux via Homebrew"
        brew install tmux
    else
        die "tmux is missing and Homebrew was not found.
   Install Homebrew first:
     /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
   then re-run this installer."
    fi
fi
ok "tmux  $(tmux -V)"

for opt in fzf zoxide; do
    if have "$opt"; then
        ok "$opt  present"
    elif have brew; then
        say "Installing $opt via Homebrew"
        brew install "$opt" >/dev/null && ok "$opt  installed" || warn "$opt install failed (optional)"
    else
        warn "$opt missing (optional; fzf powers 'tmux-switch list')"
    fi
done

# ─── 2. Upstream plugin repos ───────────────────────────────────────────
PLUGINS=(
    "tpm                tmux-plugins/tpm"
    "tmux2k             2KAbhishek/tmux2k"
    "catppuccin         catppuccin/tmux"
    "dracula            dracula/tmux"
    "rose-pine          rose-pine/tmux"
    "tokyo-night        janoamaral/tokyo-night-tmux"
    "tmux-power         wfxr/tmux-power"
    "tmux-powerline     erikw/tmux-powerline"
    "tmux-gruvbox       egel/tmux-gruvbox"
    "tmux-nova          o0th/tmux-nova"
    "tmux-battery       tmux-plugins/tmux-battery"
    "tmux-cpu           tmux-plugins/tmux-cpu"
    "tmux-online-status tmux-plugins/tmux-online-status"
)

if (( DO_PLUGINS )); then
    mkdir -p "$PLUGINS_DIR"
    say "Cloning ${#PLUGINS[@]} plugin repos into $PLUGINS_DIR"
    for line in "${PLUGINS[@]}"; do
        read -r name repo <<<"$line"
        target="$PLUGINS_DIR/$name"
        if [[ -d "$target" ]]; then
            ok "$name already present"
        else
            git clone --depth=1 "https://github.com/$repo" "$target" >/dev/null 2>&1 \
                && ok "cloned $name" \
                || warn "failed to clone $repo"
        fi
    done
else
    say "Skipping plugin repos (--minimal)"
fi

# ─── 3. Links and files ─────────────────────────────────────────────────
say "Linking"

chmod +x "$REPO_DIR/tmux-switch.sh" "$REPO_DIR/helpers/"*.sh 2>/dev/null || true

# A real file here would be silently ignored by the old installer. Back it up.
if [[ -e "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%Y%m%d-%H%M%S)"
    warn "existing ~/.tmux.conf was a real file — moved to .bak.*"
fi
if [[ -e "$HOME/.tmux-switch.sh" && ! -L "$HOME/.tmux-switch.sh" ]]; then
    mv "$HOME/.tmux-switch.sh" "$HOME/.tmux-switch.sh.bak.$(date +%Y%m%d-%H%M%S)"
fi
ln -sfn "$REPO_DIR/tmux-switch.sh" "$HOME/.tmux-switch.sh"
ok "~/.tmux-switch.sh"

[[ -f "$HOME/.tmux-theme" ]] || echo "$DEFAULT_THEME" > "$HOME/.tmux-theme"
"$REPO_DIR/tmux-switch.sh" "$(cat "$HOME/.tmux-theme")" >/dev/null
ok "theme: $(cat "$HOME/.tmux-theme")"

# ─── 4. Shell hook (idempotent, between markers) ────────────────────────
if (( DO_SHELL )) && [[ -n "${ZDOTDIR:-$HOME}" ]]; then
    RC="${ZDOTDIR:-$HOME}/.zshrc"
    touch "$RC"
    if grep -q '# >>> tmux_themes >>>' "$RC"; then
        # strip the old block so re-running never stacks duplicates
        awk '/# >>> tmux_themes >>>/{skip=1} !skip; /# <<< tmux_themes <<</{skip=0}' "$RC" > "$RC.tmp" \
            && mv "$RC.tmp" "$RC"
    fi
    cat >> "$RC" <<'HOOK'
# >>> tmux_themes >>>
[[ -f ~/.shell-theme.zsh ]] && source ~/.shell-theme.zsh
unalias tmux-switch 2>/dev/null
tmux-switch() {
    ~/.tmux-switch.sh "$@"
    [[ -f ~/.shell-theme.zsh ]] && source ~/.shell-theme.zsh
    type p10k >/dev/null 2>&1 && p10k reload 2>/dev/null
}
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
# <<< tmux_themes <<<
HOOK
    ok "~/.zshrc hook (between # >>> tmux_themes >>> markers)"
fi

# ─── 5. Verify ──────────────────────────────────────────────────────────
say "Verifying"
fail=0
[[ -L "$HOME/.tmux.conf" ]]        && ok "~/.tmux.conf -> $(readlink "$HOME/.tmux.conf")"        || { warn "~/.tmux.conf is not a symlink"; fail=1; }
[[ -L "$HOME/.shell-theme.zsh" ]]  && ok "~/.shell-theme.zsh -> $(readlink "$HOME/.shell-theme.zsh")" || warn "no shell palette for this theme (prompt colours unchanged)"
if TMUX_TMPDIR=/tmp tmux -L tt-verify -f "$HOME/.tmux.conf" start-server \; kill-server 2>/dev/null; then
    ok "tmux config parses"
else
    warn "tmux config failed to parse"; fail=1
fi
(( fail == 0 )) || die "install finished with problems (see ! lines above)"

echo
ok "Done."
echo
echo "  Open a new terminal (or: exec zsh), then:"
echo "    tmux                  start tmux"
echo "    tmux-switch list      pick a theme (fzf)"
echo "    tmux-switch           cycle to the next one"
echo
echo "  Inside tmux, prefix is Ctrl-a:"
echo "    Ctrl-a |   split left/right      Ctrl-a arrows   move between panes"
echo "    Ctrl-a -   split top/bottom      Ctrl-a h j k l  resize"
echo "    Ctrl-a z   zoom a pane           Ctrl-a i        host / IP popup"
echo
echo "  For the famous themes' glyphs, set your terminal font to a Nerd Font"
echo "  (e.g. JetBrainsMono Nerd Font Mono)."
