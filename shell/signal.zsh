# SIGNAL — the prompt half of the signal theme.
# Same three-colour rule as the status bar: accent for "you are here",
# warn only for things that need attention, neutral for everything else.
#   accent #5fafff · text #b2b2b2 · neutral #7f7f7f · warn #ffaf00 · error #ff5f5f
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#5fafff'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#7f7f7f'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#ffffff'
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#7f7f7f'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#7f7f7f'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#ffaf00'
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#7f7f7f'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#5fafff'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#ff5f5f'

typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#b2b2b2,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#b2b2b2,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#b2b2b2,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#b2b2b2,bold'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#b2b2b2,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#7f7f7f,italic'
ZSH_HIGHLIGHT_STYLES[path]='fg=#5fafff'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#3a3a3a'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#7f7f7f'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#7f7f7f'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#7f7f7f'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#7f7f7f'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#4e4e4e,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff5f5f,bold'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ffaf00'

typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#3a3a3a'

export LS_COLORS='di=38;2;95;175;255:ln=38;2;127;127;127:ex=38;2;178;178;178:fi=0:bd=38;2;255;175;0:cd=38;2;255;175;0:so=38;2;127;127;127:pi=38;2;127;127;127:or=38;2;255;95;95:mi=38;2;255;95;95:su=38;2;255;175;0:sg=38;2;255;175;0'
