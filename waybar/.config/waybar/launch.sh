#!/usr/bin/env bash
set -euo pipefail

WAYBAR_BIN="$(command -v waybar || true)"
CFG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"
STYLE_DARK="$HOME/.config/waybar/style-dark.css"
STYLE_LIGHT="$HOME/.config/waybar/style-light.css"
THEME_STATE="$HOME/.config/waybar/theme"
LOG="$HOME/.config/waybar/waybar.log"

# Prefer Wayland backend for GTK
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland

adopt_env_from_compositor() {
  # If Hyprland or Sway is running, borrow its environment so we can launch
  local pid
  pid=$(pgrep -n -x Hyprland || true)
  if [[ -z "$pid" ]]; then pid=$(pgrep -n -x sway || true); fi
  [[ -z "$pid" ]] && return 1
  local envfile="/proc/$pid/environ"
  [[ -r "$envfile" ]] || return 1
  # Export core vars if missing or empty
  while IFS= read -r line; do
    case "$line" in
      WAYLAND_DISPLAY=*|XDG_RUNTIME_DIR=*|XDG_SESSION_TYPE=*|XDG_CURRENT_DESKTOP=*|XDG_SESSION_DESKTOP=*|DBUS_SESSION_BUS_ADDRESS=*)
        local key=${line%%=*}
        local val=${line#*=}
        if [[ -z "${!key:-}" ]]; then export "$key=$val"; fi
        ;;
    esac
  done < <(tr '\0' '\n' < "$envfile")
  # Force GTK/Qt to Wayland
  export GDK_BACKEND="wayland"
  export QT_QPA_PLATFORM="wayland"
}

is_wayland_ready() {
  # Must be a wayland session and have a socket we can see
  if [[ "${XDG_SESSION_TYPE:-}" != "wayland" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "Not a Wayland session: XDG_SESSION_TYPE='${XDG_SESSION_TYPE:-}', WAYLAND_DISPLAY='${WAYLAND_DISPLAY:-}'" >&2
    adopt_env_from_compositor || return 1
  fi
  local sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/${WAYLAND_DISPLAY:-}"
  if [[ -z "${WAYLAND_DISPLAY:-}" || ! -S "$sock" ]]; then
    echo "Wayland socket missing or invalid: $sock" >&2
    adopt_env_from_compositor || return 1
  fi
  # Ensure a compositor is running (Hyprland or Sway)
  if ! pgrep -x Hyprland >/dev/null 2>&1 && ! pgrep -x sway >/dev/null 2>&1; then
    echo "No Wayland compositor process detected (Hyprland/Sway)." >&2
    return 1
  fi
  return 0
}

# Preflight checks
if ! is_wayland_ready; then
  echo "This launcher must run inside an active Wayland compositor (Hyprland/Sway)." >&2
  exit 2
fi

if [[ -z "$WAYBAR_BIN" ]]; then
  echo "waybar not found in PATH" >&2
  exit 1
fi
if [[ ! -f "$CFG" ]]; then
  echo "Config not found: $CFG" >&2
  exit 1
fi

sync_stylesheet() {
  mkdir -p "$(dirname "$STYLE")"
  local mode="dark"
  [[ -f "$THEME_STATE" ]] && mode=$(tr -d '\n' < "$THEME_STATE" 2>/dev/null || echo dark)
  local src="$STYLE_DARK"
  [[ "$mode" == "light" ]] && src="$STYLE_LIGHT"
  if [[ -f "$src" ]]; then
    # Overwrite style.css each launch so latest theme tweaks apply
    cp -f "$src" "$STYLE"
  else
    echo "/* fallback style */" > "$STYLE"
  fi
}
sync_stylesheet

# Ensure only one Waybar instance; replace existing if present
if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar || true
  # wait for clean shutdown
  for _ in {1..50}; do
    pgrep -x waybar >/dev/null 2>&1 || break
    sleep 0.1
  done
fi

# Rotate log and prepare
mkdir -p "$(dirname "$LOG")"
if [[ -f "$LOG" ]]; then
  mv -f "$LOG" "$LOG.1" || true
fi
touch "$LOG"

# Launch Waybar in background and verify it stays up briefly
{
  echo "[launch] $(date -Is) starting waybar"
  echo "[env] WAYLAND_DISPLAY='${WAYLAND_DISPLAY:-}' XDG_RUNTIME_DIR='${XDG_RUNTIME_DIR:-}' XDG_SESSION_TYPE='${XDG_SESSION_TYPE:-}' GDK_BACKEND='${GDK_BACKEND:-}'"
} >> "$LOG"
"$WAYBAR_BIN" -c "$CFG" -s "$STYLE" -l debug >> "$LOG" 2>&1 &
wb_pid=$!

# Wait up to ~1s to detect immediate failure
sleep 0.25
if ! kill -0 "$wb_pid" 2>/dev/null; then
  echo "Waybar failed to start (exited immediately). See log: $LOG" >&2
  tail -n 50 "$LOG" >&2 || true
  exit 1
fi
sleep 0.75
if ! kill -0 "$wb_pid" 2>/dev/null; then
  echo "Waybar failed to stay running. See log: $LOG" >&2
  tail -n 50 "$LOG" >&2 || true
  exit 1
fi

echo "Waybar launched (pid $wb_pid). Log: $LOG"
