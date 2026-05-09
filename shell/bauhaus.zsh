# BAUHAUS — warm palette · rosewater / peach / red
# Sourced at end of ~/.zshrc and re-sourced after `tmux-switch`.

# === Powerlevel10k prompt ===
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#f5e0dc'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#7f849c'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#fab387'
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#f38ba8'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#f38ba8'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#fab387'
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#fab387'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#f5e0dc'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#eba0ac'

# === zsh-syntax-highlighting ===
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#fab387,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#fab387,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#fab387,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#fab387,bold'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#fab387,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#fab387,italic'
ZSH_HIGHLIGHT_STYLES[path]='fg=#f5e0dc'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#585b70'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#eba0ac'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#eba0ac'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold,underline'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#eba0ac'

# === zsh-autosuggestions ===
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'

# === LS_COLORS (GNU ls / gls) — warm tones ===
export LS_COLORS='di=38;2;245;224;220:ln=38;2;243;139;168:ex=38;2;250;179;135:fi=0:bd=38;2;249;226;175:cd=38;2;249;226;175:so=38;2;235;160;172:pi=38;2;235;160;172:or=38;2;243;139;168:mi=38;2;243;139;168:su=38;2;250;179;135:sg=38;2;250;179;135'
