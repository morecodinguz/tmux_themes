#!/usr/bin/env bash
# Install tmux_themes — sets up symlinks, clones plugin repos, checks deps.
#
# Run from inside the cloned repo:
#   bash install.sh
#
# Idempotent: safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$HOME/.tmux/plugins"

say()  { printf '\033[1;35m▸\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# ─── 1. Dependency check ────────────────────────────────────────────────
say "Checking dependencies"

have tmux || { warn "tmux not installed. Install with: brew install tmux"; exit 1; }
ok "tmux  $(tmux -V)"

if ! have fzf; then
    warn "fzf not installed (used by 'tmux-switch list')"
    if have brew; then
        say "Installing fzf via Homebrew"
        brew install fzf
    else
        warn "Skipping — install manually for the interactive picker"
    fi
fi
have fzf && ok "fzf   $(fzf --version | head -1)"

# ─── 2. Plugin repos ────────────────────────────────────────────────────
mkdir -p "$PLUGINS_DIR"

declare -a PLUGINS=(
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
    # Companion plugins required by catppuccin status modules:
    "tmux-battery       tmux-plugins/tmux-battery"
    "tmux-cpu           tmux-plugins/tmux-cpu"
    "tmux-online-status tmux-plugins/tmux-online-status"
)

say "Cloning theme plugins into $PLUGINS_DIR"
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

# ─── 3. Symlinks ────────────────────────────────────────────────────────
say "Creating symlinks"

# tmux-switch script
if [[ -e "$HOME/.tmux-switch.sh" && ! -L "$HOME/.tmux-switch.sh" ]]; then
    mv "$HOME/.tmux-switch.sh" "$HOME/.tmux-switch.sh.bak.$(date +%s)"
    warn "moved existing ~/.tmux-switch.sh to .bak"
fi
ln -sfn "$REPO_DIR/tmux-switch.sh" "$HOME/.tmux-switch.sh"
chmod +x "$REPO_DIR/tmux-switch.sh"
ok "~/.tmux-switch.sh → $REPO_DIR/tmux-switch.sh"

# Helpers — make sure all are executable
chmod +x "$REPO_DIR/helpers/"*.sh
ok "helpers executable"

# Set initial theme if not set
if [[ ! -f "$HOME/.tmux-theme" ]]; then
    echo "atelier" > "$HOME/.tmux-theme"
    ok "default theme set to atelier"
fi

# Apply current theme if no .tmux.conf symlink exists
if [[ ! -L "$HOME/.tmux.conf" && ! -e "$HOME/.tmux.conf" ]]; then
    "$REPO_DIR/tmux-switch.sh" "$(cat "$HOME/.tmux-theme")" || true
fi

# ─── 4. Optional shell coloring (zsh + Powerlevel10k) ──────────────────────
say "Setup complete"
echo
echo "Next steps:"
echo "  1. Add this block to your ~/.zshrc (replace any old tmux-switch alias):"
echo
cat <<'SHELL_HOOK'
       # ─── tmux_themes integration ────────────────────────────────────
       command -v gls >/dev/null && alias ls='gls --color=auto'
       [[ -f ~/.shell-theme.zsh ]] && source ~/.shell-theme.zsh
       unalias tmux-switch 2>/dev/null
       tmux-switch() {
           ~/.tmux-switch.sh "$@"
           if [[ -f ~/.shell-theme.zsh ]]; then
               source ~/.shell-theme.zsh
               type p10k >/dev/null 2>&1 && p10k reload 2>/dev/null
           fi
       }
SHELL_HOOK
echo
echo "  2. Reload your shell, then try:"
echo "       tmux-switch list      # interactive picker (vim-style hjkl)"
echo "       tmux-switch           # cycle next theme"
echo "       tmux-switch atelier   # jump to atelier"
echo
echo "  3. For best rendering, set your terminal font to a Nerd Font"
echo "     (e.g. JetBrainsMono Nerd Font Mono)."
echo
echo "  Per-theme prompt + syntax-highlighting + ls colors will switch live"
echo "  with each tmux-switch invocation. Other open shells need to source"
echo "  ~/.zshrc again or open a new shell to pick up the new colors."
