#!/bin/sh
# Emit the Signal palette as OSC escape sequences on stdout.
#
# Sourced from ~/.zshrc so the colours follow the shell rather than an iTerm2
# profile: they then survive new tabs, an iTerm2 restart, ssh into a local
# tmux, and work in any terminal, whatever profile happens to be selected.
#
# Colours are generated from iterm/build-palette.py -- edit them there, then
# re-run it, and re-paste the ANSI list below if it changed.
[ -t 1 ] || exit 0

seq=''
i=0
for c in 15181c e05252 6fcf7f e5a13a 5fafff b98cff 4fc9c9 a9b6c4 \
         6b7280 d77757 8ee79a ffc75a 8ac6ff d7b3ff 7fe3e3 e8e3f2; do
    seq="${seq}$(printf '\033]4;%d;rgb:%s/%s/%s\007' "$i" \
        "$(echo "$c" | cut -c1-2)" "$(echo "$c" | cut -c3-4)" "$(echo "$c" | cut -c5-6)")"
    i=$((i+1))
done
seq="${seq}$(printf '\033]10;rgb:c6/c6/c6\007')"   # default foreground
seq="${seq}$(printf '\033]11;rgb:0f/13/19\007')"   # default background
seq="${seq}$(printf '\033]12;rgb:5f/af/ff\007')"   # cursor

if [ -n "$TMUX" ]; then
    # tmux swallows OSC unless it is wrapped in a DCS passthrough
    printf '\033Ptmux;%s\033\\' "$(printf '%s' "$seq" | sed 's/\o033/\o033\o033/g')"
else
    printf '%s' "$seq"
fi
