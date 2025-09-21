#!/usr/bin/env bash
set -euo pipefail

WAYBAR_BIN="$(command -v waybar || true)"
CFG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"
STYLE_DARK="$HOME/.config/waybar/style-dark.css"
LOG="$HOME/.config/waybar/waybar.log"

# Preflight checks
if [[ -z "$WAYBAR_BIN" ]]; then
  echo "waybar not found in PATH" >&2
  exit 1
fi
if [[ ! -f "$CFG" ]]; then
  echo "Config not found: $CFG" >&2
  exit 1
fi

# Ensure style.css exists (default to dark)
mkdir -p "$(dirname "$STYLE")"
if [[ ! -f "$STYLE" ]]; then
  if [[ -f "$STYLE_DARK" ]]; then
    cp -f "$STYLE_DARK" "$STYLE"
  else
    echo "/* fallback style */" > "$STYLE"
  fi
fi

# Ensure only one Waybar instance; replace existing if present
if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar || true
  # wait for clean shutdown
  for _ in {1..50}; do
    pgrep -x waybar >/dev/null 2>&1 || break
    sleep 0.1
  done
fi

# Rotate log
mkdir -p "$(dirname "$LOG")"
if [[ -f "$LOG" ]]; then
  mv -f "$LOG" "$LOG.1" || true
fi

# Launch Waybar, detached, with logging
(
  echo "[launch] $(date -Is) starting waybar" >> "$LOG"
  exec "$WAYBAR_BIN" \
    -c "$CFG" \
    -s "$STYLE" \
    >> "$LOG" 2>&1
) &
setsid -f bash -c 'sleep 0.01' >/dev/null 2>&1 || true
echo "Waybar launch attempted. Check log: $LOG"
