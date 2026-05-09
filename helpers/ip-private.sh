#!/usr/bin/env bash
# Print the active LAN IP (en0 wifi/ethernet, fallback to en1).
# Output: "172.16.92.47" or "—" if no IP.
ip=$(ipconfig getifaddr en0 2>/dev/null)
[[ -z "$ip" ]] && ip=$(ipconfig getifaddr en1 2>/dev/null)
[[ -z "$ip" ]] && ip=$(ipconfig getifaddr en2 2>/dev/null)
echo "${ip:-—}"
