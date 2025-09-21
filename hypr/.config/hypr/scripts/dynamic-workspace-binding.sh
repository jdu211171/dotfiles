#!/usr/bin/env bash
set -euo pipefail

# Dynamically bind workspaces 1–10 to the external monitor when present,
# otherwise bind them to the laptop panel (eDP-*). Also move existing
# workspaces to the chosen monitor. Intended to be launched via Hyprland
# `exec-once` and to watch hotplug events through socket2.
#
# Requirements: hyprctl, jq. Optional: socat (or netcat with -U) for IPC events.

log() { printf "[ws-dynamic] %s\n" "$*" >&2; }
err() { printf "[ws-dynamic][ERR] %s\n" "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

require() {
  for bin in "$@"; do
    if ! have "$bin"; then
      err "Missing required command: $bin"
      exit 1
    fi
  done
}

require hyprctl jq

HCTL=${HYPRCTL:-hyprctl}

monitors_json() { "$HCTL" -j monitors; }
workspaces_json() { "$HCTL" -j workspaces; }

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

# Return existing numeric workspace IDs (1..10) and their current monitor
existing_ws_1_10() {
  workspaces_json | jq -r 'map(select((.id // 0) >= 1 and (.id <= 10))) | .[] | "\(.id) \(.monitor)"'
}

batch_keyword_workspaces() {
  local dest=$1; shift
  local -a cmds=()
  for i in $(seq 1 10); do
    if [[ $i -eq 1 ]]; then
      cmds+=("keyword workspace $i, monitor:$dest, default:true")
    else
      cmds+=("keyword workspace $i, monitor:$dest")
    fi
  done
  local joined
  joined=$(IFS=' ; '; printf '%s' "${cmds[*]}")
  "$HCTL" --batch "$joined" >/dev/null 2>&1 || true
}

move_existing_to() {
  local dest=$1
  while read -r line; do
    [[ -z $line ]] && continue
    local id mon
    id=${line%% *}
    mon=${line#* }
    if [[ "$mon" != "$dest" ]]; then
      "$HCTL" --quiet dispatch moveworkspacetomonitor "$id" "$dest" >/dev/null 2>&1 || true
    fi
  done < <(existing_ws_1_10)
}

focus_dest_ws1() {
  local dest=$1
  "$HCTL" --quiet dispatch focusmonitor "$dest" >/dev/null 2>&1 || true
  "$HCTL" --quiet dispatch workspace 1 >/dev/null 2>&1 || true
}

sync_once() {
  local int ext dest
  int=$(internal_name)
  ext=$(pick_external "$int")
  if [[ -n "$ext" ]]; then
    dest=$ext
  else
    dest=$int
  fi
  if [[ -z "$dest" ]]; then
    err "No suitable monitor found (no eDP-* and no external active)."
    return 0
  fi
  log "Binding workspaces 1–10 to $dest"
  batch_keyword_workspaces "$dest"
  move_existing_to "$dest"
  focus_dest_ws1 "$dest"
}

listen_events() {
  local sock
  sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
  [[ -S "$sock" ]] || { err "socket2 not found: $sock"; return 1; }

  if have socat; then
    socat -U - UNIX-CONNECT:"$sock"
  elif have nc; then
    # shellcheck disable=SC2034
    nc -U "$sock"
  else
    err "Neither socat nor nc found; cannot subscribe to events."
    return 1
  fi
}

daemon() {
  # Initial sync right away
  sync_once

  # Subscribe to monitor hotplug events and resync
  listen_events | while read -r ev; do
    case "$ev" in
      monitoradded*|monitorremoved*)
        log "Event: $ev — resyncing bindings"
        sync_once
        ;;
    esac
  done
}

case "${1:-}" in
  --once|--sync|--initial-sync)
    sync_once ;;
  --daemon|--watch)
    daemon ;;
  *)
    echo "Usage: $0 [--once|--daemon]" >&2
    exit 2 ;;
esac

