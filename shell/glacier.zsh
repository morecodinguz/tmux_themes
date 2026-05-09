# GLACIER — cool palette · lavender / sapphire / green
# Sourced at end of ~/.zshrc and re-sourced after `tmux-switch`.

# === Powerlevel10k prompt ===
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#b4befe'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#7f849c'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#cdd6f4'
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#74c7ec'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#74c7ec'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#fab387'
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#94e2d5'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#b4befe'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#f38ba8'

# === zsh-syntax-highlighting ===
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
ZSH_HIGHLIGHT_STYLES[path]='fg=#74c7ec'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#585b70'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#94e2d5'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#94e2d5'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#b4befe'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#b4befe'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#585b70,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#b4befe'

# === zsh-autosuggestions ===
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'

# === LS_COLORS (GNU ls / gls) — cool tones ===
export LS_COLORS='di=38;2;180;190;254:ln=38;2;116;199;236:ex=38;2;166;227;161:fi=0:bd=38;2;148;226;213:cd=38;2;148;226;213:so=38;2;137;180;250:pi=38;2;137;220;235:or=38;2;243;139;168:mi=38;2;243;139;168:su=38;2;166;227;161:sg=38;2;166;227;161'
