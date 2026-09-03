#!/usr/bin/env python3
"""Single source of truth for the Signal 16-colour palette.

Claude Code's "dark-ansi" theme maps its semantic roles onto the terminal's own
16 ANSI colours (read out of the 2.1.259 binary):

  0  black        text drawn on light blocks
  1  red          error, diffRemoved
  2  green        success, diffAdded
  3  yellow       warning, rate-limit bar
  4  blue         permission, suggestion, remember, briefLabelYou
  5  magenta      bashBorder, skill, autoAccept, effortUltra
  6  cyan         planMode, selectionBg
  7  white        userMessageBackground  <-- the block around YOUR message
  8  brightBlack  subtle, inactive
  9  brightRed    claude (its own name/spinner), diffRemovedWord
  10 brightGreen  diffAddedWord
  11 brightYellow warningShimmer
  12 brightBlue   ide, professionalBlue
  13 brightMagenta autoAcceptShimmer
  14 brightCyan   rainbow_blue_shimmer
  15 brightWhite  bashMessageBackgroundColor  <-- the block around BASH output

So 7 and 15 are not text colours here, they are the two message-block
backgrounds. Tinting them apart is what makes your messages, Claude's prose and
bash blocks read as three different things.

Usage:
  python3 build-palette.py            # rewrite the preset + dynamic profile
  python3 build-palette.py /dev/ttys8 # also push it live to a running terminal
"""
import json, os, sys

PALETTE = {
    "Background Color": "#0f1319",
    "Foreground Color": "#c6c6c6",
    "Bold Color":       "#ffffff",
    "Cursor Color":     "#5fafff",
    "Cursor Text Color":"#0f1319",
    "Selection Color":  "#1e3a5f",
    "Selected Text Color":"#ffffff",
    "Link Color":       "#5fafff",
    "Badge Color":      "#e5a13a",
}
ANSI = [
    "#15181c",  # 0  text on light blocks
    "#e05252",  # 1  error / diffRemoved
    "#6fcf7f",  # 2  success / diffAdded
    "#e5a13a",  # 3  warning
    "#5fafff",  # 4  permission / suggestion / your label
    "#b98cff",  # 5  bashBorder / skill
    "#4fc9c9",  # 6  planMode
    "#a9b6c4",  # 7  YOUR message block  (cool blue-grey)
    "#6b7280",  # 8  subtle / inactive
    "#d77757",  # 9  Claude's own orange -- same rgb(215,119,87) the non-ansi theme uses
    "#8ee79a",  # 10 diffAddedWord
    "#ffc75a",  # 11 warningShimmer
    "#8ac6ff",  # 12 ide
    "#d7b3ff",  # 13 autoAcceptShimmer
    "#7fe3e3",  # 14 shimmer cyan
    "#e8e3f2",  # 15 BASH block  (faint violet-white, matches the magenta border)
]

def comp(h):
    r, g, b = (int(h[i:i+2], 16) / 255 for i in (1, 3, 5))
    return r, g, b

def plist_entry(h):
    r, g, b = comp(h)
    return ("\t<dict>\n\t\t<key>Alpha Component</key><real>1</real>\n"
            "\t\t<key>Blue Component</key><real>%.6f</real>\n"
            "\t\t<key>Color Space</key><string>sRGB</string>\n"
            "\t\t<key>Green Component</key><real>%.6f</real>\n"
            "\t\t<key>Red Component</key><real>%.6f</real>\n\t</dict>") % (b, g, r)

def json_color(h):
    r, g, b = comp(h)
    return {"Color Space": "sRGB", "Red Component": r,
            "Green Component": g, "Blue Component": b, "Alpha Component": 1}

here = os.path.dirname(os.path.abspath(__file__))
allc = dict(PALETTE)
for i, h in enumerate(ANSI):
    allc["Ansi %d Color" % i] = h

# 1. .itermcolors preset (importable anywhere)
out = ['<?xml version="1.0" encoding="UTF-8"?>',
       '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" '
       '"http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
       '<plist version="1.0">', '<dict>']
for k in sorted(allc):
    out += ['\t<key>%s</key>' % k, plist_entry(allc[k])]
out += ['</dict>', '</plist>', '']
open(os.path.join(here, "signal.itermcolors"), "w").write("\n".join(out))

# 2. iTerm2 dynamic profile (live, no restart, no import dialog)
prof = {"Name": "Signal",
        "Guid": "E5F1A7C2-51GN-4A10-9D33-5163414C0001",
        "Dynamic Profile Parent Name": "Default",
        "Transparency": 0.0, "Blur": False,
        "Minimum Contrast": 0.0, "Use Bright Bold": False}
for k, h in allc.items():
    prof[k] = json_color(h)
dyn = os.path.expanduser("~/Library/Application Support/iTerm2/DynamicProfiles")
os.makedirs(dyn, exist_ok=True)
json.dump({"Profiles": [prof]}, open(os.path.join(dyn, "signal.json"), "w"), indent=2)
json.dump({"Profiles": [prof]}, open(os.path.join(here, "signal-dynamic-profile.json"), "w"), indent=2)

# 3. optionally push live to a tty (wrapped so it survives tmux)
if len(sys.argv) > 1:
    tty = sys.argv[1]
    rgb = lambda h: "rgb:%s/%s/%s" % (h[1:3], h[3:5], h[5:7])
    seq = "".join("\x1b]4;%d;%s\x07" % (i, rgb(h)) for i, h in enumerate(ANSI))
    seq += "\x1b]10;%s\x07" % rgb(PALETTE["Foreground Color"])
    seq += "\x1b]11;%s\x07" % rgb(PALETTE["Background Color"])
    seq += "\x1b]12;%s\x07" % rgb(PALETTE["Cursor Color"])
    open(tty, "w").write("\x1bPtmux;" + seq.replace("\x1b", "\x1b\x1b") + "\x1b\\")
    print("pushed live to", tty)

print("wrote signal.itermcolors, signal-dynamic-profile.json, and the live iTerm2 profile")
