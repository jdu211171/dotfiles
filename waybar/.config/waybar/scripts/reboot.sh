#!/usr/bin/env bash
set -euo pipefail

# Waybar custom module: reboot icon and action
# - Without args: prints JSON with icon and tooltip
# - With "run": triggers system reboot

icon="󰜉"  # Nerd Font: nf-md-restart
tooltip="Restart"

if [[ "${1:-}" == "run" ]]; then
  systemctl reboot
  exit 0
fi

printf '{"text":"%s","tooltip":"%s","class":"reboot"}\n' "$icon" "$tooltip"

