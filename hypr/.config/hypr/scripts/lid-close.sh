#!/usr/bin/env bash
set -euo pipefail

# Safely handle laptop lid close in Hyprland.
# - If any external monitor is active, disable the internal panel (eDP-1)
#   so all workspaces move to the external monitor automatically.
# - If no external monitor is active, do nothing to avoid turning off the
#   last/only display.

HCTL=${HYPRCTL:-hyprctl}
INTERNAL=${INTERNAL_OUTPUT:-eDP-1}

have() { command -v "$1" >/dev/null 2>&1; }

if ! have jq; then
  echo "[lid-close] Missing 'jq' (required). Skipping." >&2
  exit 0
fi

if "$HCTL" -j monitors | jq -e --arg int "$INTERNAL" '
  map(select(.name != $int and (.dpmsStatus==true) and (.disabled|not // true)))
  | length > 0
' >/dev/null; then
  "$HCTL" --batch "keyword monitor $INTERNAL,disable" >/dev/null 2>&1 || true
  # Give Hyprland a moment to finalize layout, then reassert wallpaper
  sleep 0.15
  if [ -f "$HOME/.config/hypr/themes/fuji.jpg" ]; then
    "$HCTL" hyprpaper wallpaper ",/home/user/.config/hypr/themes/fuji.jpg" >/dev/null 2>&1 || true
  fi
else
  # No external monitors are active — keep the internal on.
  :
fi
