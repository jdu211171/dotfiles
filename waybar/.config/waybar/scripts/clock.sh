#!/usr/bin/env bash
set -euo pipefail

# Waybar custom clock: JSON output with icon and tooltip
# Honors TZ via config or environment; defaults to system timezone

ICON="󰥔"  # MDI clock-outline

# Date formats
FMT_MAIN="%a %b %d %H:%M"      # Wed Sep 10 10:35
FMT_TOOLTIP_MAIN="%A, %B %d %Y" # Wednesday, September 10 2025
FMT_TOOLTIP_WEEK="%V"           # ISO week number

# Default to Tokyo to match previous config; override via ~/.config/waybar/clock.timezone
TZ_FILE="$HOME/.config/waybar/clock.timezone"
if [[ -f "$TZ_FILE" ]]; then
  export TZ="$(tr -d '\n' < "$TZ_FILE")"
else
  export TZ="Asia/Tokyo"
fi

main_text="$(date +"$FMT_MAIN")"
tooltip="$(date +"$FMT_TOOLTIP_MAIN")\nWeek $(date +"$FMT_TOOLTIP_WEEK")"

# Emit JSON
printf '{"text":"%s %s","tooltip":"%s"}\n' "$ICON" "$main_text" "$tooltip"
