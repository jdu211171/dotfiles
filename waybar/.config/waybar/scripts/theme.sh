#!/usr/bin/env bash
set -euo pipefail

WAYBAR_DIR="$HOME/.config/waybar"
STYLE_CSS="$WAYBAR_DIR/style.css"
STYLE_DARK="$WAYBAR_DIR/style-dark.css"
STYLE_LIGHT="$WAYBAR_DIR/style-light.css"
STATE_FILE="$WAYBAR_DIR/theme"

reload_waybar() { pkill -SIGUSR2 waybar >/dev/null 2>&1 || true; }

ensure_state() {
  # Initialize state if missing
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "dark" > "$STATE_FILE"
  fi
}

# Read current appearance from portal first, then gsettings, fallback to state file
read_portal_mode() {
  local raw
  raw=$(gdbus call --session \
    --dest org.freedesktop.portal.Desktop \
    --object-path /org/freedesktop/portal/desktop \
    --method org.freedesktop.portal.Settings.Read \
    "org.freedesktop.appearance" "color-scheme" 2>/dev/null || true)
  if [[ -z "${raw:-}" ]]; then return 1; fi
  local val
  val=$(awk '/uint32/ {print $2}' <<<"$raw" | tr -d '),')
  case "${val:-0}" in
    1) echo dark ;;
    2) echo light ;;
    *) return 1 ;;
  esac
}

read_gsettings_mode() {
  local v
  v=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'default'")
  case "$v" in
    *prefer-dark*) echo dark ;;
    *prefer-light*) echo light ;;
    *) return 1 ;;
  esac
}

current_mode() {
  if m=$(read_portal_mode); then echo "$m"; return; fi
  if m=$(read_gsettings_mode); then echo "$m"; return; fi
  [[ -f "$STATE_FILE" ]] && tr -d '\n' < "$STATE_FILE" || echo dark
}

apply_mode() {
  local mode="$1"
  mkdir -p "$WAYBAR_DIR"
  local target="$STYLE_DARK"; [[ "$mode" == "light" ]] && target="$STYLE_LIGHT"
  # Write atomically to avoid disappearing bar during reload
  local tmp="$STYLE_CSS.tmp.$$"
  if ! cp -f "$target" "$tmp" 2>/dev/null; then
    echo "Failed to prepare theme stylesheet: $target" >&2
    return 1
  fi
  mv -f "$tmp" "$STYLE_CSS"
  echo "$mode" > "$STATE_FILE"
}


emit_status() {
  local mode; mode=$(current_mode)
  local icon tooltip
  if [[ "$mode" == "light" ]]; then
    icon="󰖨"; tooltip="Light mode"
  else
    icon="󰖔"; tooltip="Dark mode"
  fi
  # Output JSON for Waybar custom module
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$mode"
}

set_portal_mode() {
  # Write the GSettings value; portal will emit a signal
  local mode="$1"
  case "$mode" in
    dark)  gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true ;;
    light) gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null || true ;;
  esac
}

cmd="${1:-status}"
case "$cmd" in
  toggle)
    ensure_state
    cur=$(current_mode)
    if [[ "$cur" == "light" ]]; then next="dark"; else next="light"; fi
    # Update the system-wide preference via GSettings/portal
    set_portal_mode "$next"
    # Apply local tweaks (Waybar CSS, etc.)
    apply_mode "$next"
    # Only hot-reload Waybar; no app signals or restarts
    reload_waybar
    emit_status
    ;;
  status|*)
    ensure_state
    emit_status
    ;;
esac
