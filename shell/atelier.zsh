# ATELIER — pastel palette · mauve / lavender / peach / pink
# Sourced at end of ~/.zshrc and re-sourced after `tmux-switch`.

# === Powerlevel10k prompt ===
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#cba6f7'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#7f849c'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#cdd6f4'
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#fab387'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#fab387'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#f9e2af'
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#f5c2e7'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#cba6f7'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#f38ba8'

# === zsh-syntax-highlighting ===
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[function]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#cba6f7,italic'
ZSH_HIGHLIGHT_STYLES[path]='fg=#b4befe'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#585b70'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#585b70,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f9e2af'

# === zsh-autosuggestions ===
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'

# === LS_COLORS (GNU ls / gls) — pastel tones ===
export LS_COLORS='di=38;2;203;166;247:ln=38;2;180;190;254:ex=38;2;250;179;135:fi=0:bd=38;2;249;226;175:cd=38;2;249;226;175:so=38;2;245;194;231:pi=38;2;245;194;231:or=38;2;243;139;168:mi=38;2;243;139;168:su=38;2;250;179;135:sg=38;2;250;179;135'
