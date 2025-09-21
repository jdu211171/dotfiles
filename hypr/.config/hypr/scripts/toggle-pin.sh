#!/usr/bin/env bash
set -euo pipefail

# Toggle Hyprland "pinned" state for the active window.
# - If the window is tiled, make it floating first (required for pin).
# - On unpin, restore tiling if we floated it earlier.

err() { printf "[toggle-pin] %s\n" "$*" >&2; }

json=$(hyprctl -j activewindow 2>/dev/null || true)
if [[ -z "$json" || "$json" == "null" ]]; then
  err "No active window."
  exit 1
fi

addr=$(jq -r '.address' <<<"$json")
pinned=$(jq -r '.pinned' <<<"$json")
floating=$(jq -r '.floating' <<<"$json")
title=$(jq -r '.title' <<<"$json")
class=$(jq -r '.class' <<<"$json")

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-pin"
mkdir -p "$state_dir"
state_file="$state_dir/${addr}.state"

notify() {
  local msg="$*"
  if command -v notify-send >/dev/null 2>&1; then
    # Use desktop notifications (mako/swaync/dunst) for nicer styling
    notify-send -a "Hypr Pin" -i "pin" -u low "${msg}" || true
  else
    # Fallback to Hyprland built-in notify
    hyprctl --quiet notify 0 2200 0 "$msg" >/dev/null 2>&1 || true
  fi
}

if [[ "$pinned" == "false" ]]; then
  unfloat_on_unpin=0
  if [[ "$floating" == "false" ]]; then
    hyprctl --quiet dispatch togglefloating active || true
    unfloat_on_unpin=1
  fi
  hyprctl --quiet dispatch pin active || true
  printf 'unfloat_on_unpin=%s\n' "$unfloat_on_unpin" >"$state_file"
  notify "Pinned: ${title} (${class})"
else
  # Currently pinned → unpin and restore tiling if we floated earlier
  hyprctl --quiet dispatch pin active || true
  if [[ -f "$state_file" ]]; then
    # shellcheck disable=SC1090
    source "$state_file" || true
    rm -f "$state_file"
    if [[ ${unfloat_on_unpin:-0} -eq 1 ]]; then
      hyprctl --quiet dispatch togglefloating active || true
    fi
  fi
  notify "Unpinned: ${title} (${class})"
fi
