#!/usr/bin/env bash
set -euo pipefail

# Move workspaces off the laptop panel (eDP-*) to an external monitor when the lid closes,
# and optionally restore them when the lid opens. Designed for Hyprland on Wayland.
#
# Usage (called by Hyprland bindswitch):
#   lid-workspace-redirect.sh close   # lid closed
#   lid-workspace-redirect.sh open    # lid opened
#
# Requirements: hyprctl, jq, bash. notify-send is optional.

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a "Hypr Lid" -u low "$@" || true
}

err() { printf "[lid-redirect] %s\n" "$*" >&2; }
log() { printf "[lid-redirect] %s\n" "$*" >&2; }

HYPRCTL=${HYPRCTL:-hyprctl}
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$STATE_DIR/hypr-lid-moved.json"

have() { command -v "$1" >/dev/null 2>&1; }

require() {
  for bin in "$@"; do
    if ! have "$bin"; then
      err "Missing required command: $bin"
      exit 1
    fi
  done
}

require "$HYPRCTL" jq

monitors_json() { "$HYPRCTL" -j monitors; }
workspaces_json() { "$HYPRCTL" -j workspaces; }

# Returns first monitor name that looks like an embedded panel (eDP-*).
internal_name() {
  monitors_json | jq -r 'map(select(.name | test("^eDP(-|$)"))) | .[0].name // empty'
}

# Pick the largest active external monitor (dpmsStatus==true and not eDP-*).
pick_external() {
  local internal=$1
  monitors_json | jq -r --arg internal "$internal" '
    map(select(.name != $internal and (.dpmsStatus==true) and (.disabled|not // true)))
    | sort_by((.width // 0) * (.height // 0))
    | reverse
    | .[0].name // empty'
}

focused_ws_on() {
  local mon=$1
  monitors_json | jq -r --arg mon "$mon" 'map(select(.name==$mon)) | .[0].activeWorkspace.id // empty'
}

workspaces_on_monitor() {
  local mon=$1
  # Return numeric workspace IDs assigned to monitor $mon (exclude special workspaces)
  workspaces_json | jq -r --arg mon "$mon" '
    map(select((.id // 0) >= 1 and (.name | startswith("special:") | not) and .monitor==$mon) | .id)
    | .[]'
}

movews() {
  local ws=$1 dest=$2
  "$HYPRCTL" --quiet dispatch moveworkspacetomonitor "$ws" "$dest" >/dev/null 2>&1 || true
}

focus_monitor_ws() {
  local mon=$1 ws=$2
  "$HYPRCTL" --quiet dispatch focusmonitor "$mon" >/dev/null 2>&1 || true
  if [[ -n "${ws:-}" ]]; then
    "$HYPRCTL" --quiet dispatch workspace "$ws" >/dev/null 2>&1 || true
  fi
}

save_state() {
  local internal=$1 external=$2 focused=$3
  shift 3
  local -a moved=("$@")
  jq -n --arg internal "$internal" --arg external "$external" --argjson focused ${focused:-null} \
        --argjson ws "$(printf '%s\n' "${moved[@]}" | jq -Rcs 'split("\n")|map(select(length>0))|map(tonumber)')" \
        '{internal:$internal, external:$external, focused:$focused, ws:$ws}' >"$STATE_FILE" 2>/dev/null || true
}

load_state() {
  [[ -f "$STATE_FILE" ]] || return 1
  cat "$STATE_FILE"
}

case ${1:-} in
  close)
    int=$(internal_name)
    if [[ -z "$int" ]]; then
      err "No internal eDP-* monitor detected. Nothing to move."
      exit 0
    fi
    ext=$(pick_external "$int")
    if [[ -z "$ext" ]]; then
      # No active external monitor — leave as-is.
      log "No active external monitor found; skipping moves."
      exit 0
    fi

    mapfile -t ws_ids < <(workspaces_on_monitor "$int")
    focused=$(focused_ws_on "$int")
    if (( ${#ws_ids[@]} == 0 )); then
      # Fallback: try moving the currently active workspace on the internal panel
      if [[ -n "${focused:-}" ]]; then
        ws_ids=("$focused")
      else
        log "No workspaces on $int to move."
        exit 0
      fi
    fi
    for w in "${ws_ids[@]}"; do
      movews "$w" "$ext"
    done
    save_state "$int" "$ext" "${focused:-null}" "${ws_ids[@]}"
    focus_monitor_ws "$ext" "${focused:-}"
    notify "Moved workspaces [${ws_ids[*]}] from $int → $ext"
    ;;

  open)
    st=$(load_state) || {
      # Nothing saved; optionally move only workspace 1 back if eDP is present
      int=$(internal_name)
      if [[ -n "$int" ]]; then
        # best effort: if WS 1 is not on internal, move it back
        current_mon_ws1=$(workspaces_json | jq -r 'map(select(.id==1)) | .[0].monitor // empty')
        if [[ -n "$current_mon_ws1" && "$current_mon_ws1" != "$int" ]]; then
          movews 1 "$int"
          focus_monitor_ws "$int" 1
          notify "Restored workspace 1 to $int"
        fi
      fi
      exit 0
    }

    int=$(jq -r '.internal // empty' <<<"$st")
    ext=$(jq -r '.external // empty' <<<"$st")
    focused=$(jq -r '.focused // empty' <<<"$st")
    mapfile -t ws_ids < <(jq -r '.ws[]? // empty' <<<"$st")

    if [[ -z "$int" || ${#ws_ids[@]} -eq 0 ]]; then
      log "State incomplete; nothing to restore."
      exit 0
    fi

    # Ensure internal is back and active
    if ! monitors_json | jq -e --arg int "$int" 'any(.name==$int and .dpmsStatus==true)' >/dev/null; then
      log "Internal monitor $int not active; skipping restore."
      exit 0
    fi

    for w in "${ws_ids[@]}"; do
      movews "$w" "$int"
    done
    focus_monitor_ws "$int" "${focused:-}"
    rm -f "$STATE_FILE" 2>/dev/null || true
    notify "Restored workspaces [${ws_ids[*]}] to $int"
    ;;

  *)
    err "Usage: $0 {close|open}"
    exit 2
    ;;
esac
