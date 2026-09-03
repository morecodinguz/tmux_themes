#!/bin/bash
# Shows how the current terminal palette renders the things Claude Code draws.
# The role labels come from the dark-ansi mapping inside the Claude Code binary.
e=$'\033'; R="${e}[0m"
fg(){ printf '%s[38;5;%dm' "$e" "$1"; }
bg(){ printf '%s[48;5;%dm' "$e" "$1"; }
bar(){ printf '%s[1m%s%s\n' "$e" "$1" "$R"; }

clear
bar "  YOUR 16 COLOURS, AND WHAT CLAUDE CODE DRAWS WITH EACH"
echo
roles=( "0 text on blocks" "1 error / diff removed" "2 success / diff added" "3 warning"
        "4 permission · suggestion" "5 bash border · skill" "6 plan mode" "7 YOUR MESSAGE BLOCK"
        "8 subtle / inactive" "9 Claude itself" "10 diff added word" "11 warning shimmer"
        "12 IDE" "13 auto-accept" "14 shimmer cyan" "15 BASH BLOCK" )
for i in {0..15}; do
    printf '   %s      %s %s%-2d%s %s\n' "$(bg $i)" "$R" "$(fg $i)" "$i" "$R" "${roles[$i]}"
done

echo
bar "  HOW THE THREE BLOCK TYPES LOOK"
echo
printf '   %s%s  you  ›  lets test all things we have changed here          %s\n' "$(bg 7)" "$(fg 0)" "$R"
echo
printf '   %s Claude  Plain prose sits on the terminal background, in the%s\n' "$(fg 9)" "$R"
printf '           default foreground colour. Inline code like %s~/.tmux.conf%s\n' "$(fg 4)" "$R"
printf '           is drawn in %sblue%s.\n' "$(fg 4)" "$R"
echo
printf '   %s%s  $ git status --short                                       %s\n' "$(bg 15)" "$(fg 0)" "$R"
printf '   %s   └─ bash block: background 15, border colour 5%s\n' "$(fg 5)" "$R"
echo
bar "  A CODE BLOCK (no background — Claude Code has no key for one)"
echo
printf '   %sdef %sload_model%s(path: str) -> Model:%s\n'     "$(fg 5)" "$(fg 12)" "$(fg 7)" "$R"
printf '       %s# comment%s\n'                                "$(fg 8)" "$R"
printf '       %sreturn%s Model.from_pretrained(%s"swin-base"%s)%s\n' "$(fg 5)" "$R" "$(fg 2)" "$R" "$R"
echo
printf '   %s+ added line%s        %s- removed line%s        %swarning%s        %serror%s\n' \
       "$(fg 2)" "$R" "$(fg 1)" "$R" "$(fg 3)" "$R" "$(fg 1)" "$R"
echo
bar "  The tmux status bar is at the bottom of this screen."
echo
echo "   Press q to close this window."
while read -rsn1 k; do [[ $k == q ]] && break; done
