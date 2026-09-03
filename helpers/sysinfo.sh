#!/bin/sh
# prefix + i -- the things that used to sit in the status bar forever.
H="$(dirname "$0")"
printf '\n'
printf '   host   %s\n' "$(hostname -s)"
printf '   lan    %s\n' "$("$H/ip-private.sh")"
printf '   wan    %s\n' "$("$H/ip-public.sh")"
printf '   up     %s\n' "$(uptime | sed 's/.*up *//; s/,[^,]*users.*//')"
printf '   load   %s\n' "$(uptime | sed 's/.*averages*: *//')"
printf '\n   press any key to close\n'
stty raw -echo 2>/dev/null; dd bs=1 count=1 >/dev/null 2>&1; stty sane 2>/dev/null
