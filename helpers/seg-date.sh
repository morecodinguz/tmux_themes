#!/bin/sh
# Status segment: date, forced to ASCII. The Korean locale renders this as
# "목 03  9월" -- double-width glyphs in the status bar, which is exactly the
# class of thing that makes tmux and the terminal disagree about column widths.
LC_ALL=C date '+%a %d %b'
