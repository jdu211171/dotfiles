#!/usr/bin/env bash
set -euo pipefail

# Waybar custom module: shutdown icon and action
# - Without args: prints JSON with icon and tooltip
# - With "run": triggers system shutdown

icon="󰐥"  # Nerd Font: nf-md-power
tooltip="Power off"

if [[ "${1:-}" == "run" ]]; then
  # Use systemctl; polkit may prompt if required
  systemctl poweroff
  exit 0
fi

# Output JSON for Waybar
printf '{"text":"%s","tooltip":"%s","class":"shutdown"}\n' "$icon" "$tooltip"
