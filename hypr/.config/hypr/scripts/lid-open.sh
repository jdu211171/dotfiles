#!/usr/bin/env bash
set -euo pipefail

# Re-enable the internal panel with your preferred mode/scale when the lid opens.
# Keep this in sync with your monitors.conf entry for eDP-1.

HCTL=${HYPRCTL:-hyprctl}
INTERNAL=${INTERNAL_OUTPUT:-eDP-1}
MODELINE=${INTERNAL_MODELINE:-"1920x1080@60,0x0,1.5"}

"$HCTL" --batch "keyword monitor $INTERNAL,$MODELINE" >/dev/null 2>&1 || true
sleep 0.15
if [ -f "$HOME/.config/hypr/themes/fuji.jpg" ]; then
  "$HCTL" hyprpaper wallpaper ",${HOME}/.config/hypr/themes/fuji.jpg" >/dev/null 2>&1 || true
fi
