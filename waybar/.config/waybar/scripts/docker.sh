#!/usr/bin/env bash
set -euo pipefail

icon_on=""
icon_off=""

service_name="${DOCKER_SERVICE:-docker}"
scope="${DOCKER_SCOPE:-system}" # system | user | auto

json_escape() {
  python3 -c 'import json, sys; print(json.dumps(sys.stdin.read(), ensure_ascii=False)[1:-1])'
}

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

send_notification() {
  local message="$1"
  if cmd_exists notify-send; then
    notify-send --app-name="Waybar" "Docker" "$message" || true
  fi
}

resolve_scope() {
  case "$scope" in
    system|user)
      return
      ;;
    auto)
      if systemctl --user show "$service_name" >/dev/null 2>&1; then
        scope="user"
      else
        scope="system"
      fi
      ;;
    *)
      scope="system"
      ;;
  esac
}

current_status="unknown"
current_scope="system"

detect_status() {
  resolve_scope
  current_scope="$scope"

  local status
  if [[ "$current_scope" == "user" ]]; then
    status=$(systemctl --user is-active "$service_name" 2>/dev/null || true)
  else
    status=$(systemctl is-active "$service_name" 2>/dev/null || true)
  fi

  if [[ -z "$status" ]]; then
    status="unknown"
  fi
  current_status="$status"
}

control_daemon() {
  local action="$1"
  resolve_scope

  if [[ "$scope" == "user" ]]; then
    systemctl --user "$action" "$service_name"
    return $?
  fi

  if systemctl "$action" "$service_name" >/dev/null 2>&1; then
    return 0
  fi

  if cmd_exists pkexec; then
    pkexec systemctl "$action" "$service_name"
    return $?
  fi

  if cmd_exists sudo; then
    if sudo -n systemctl "$action" "$service_name" >/dev/null 2>&1; then
      return 0
    fi
    sudo systemctl "$action" "$service_name"
    return $?
  fi

  systemctl "$action" "$service_name"
}

count_containers() {
  docker ps --format '{{.Names}}' 2>/dev/null
}

build_output() {
  if ! cmd_exists systemctl; then
    printf '{"text":"%s","class":"unavailable","tooltip":"systemctl not available"}\n' "$(printf '%s' "$icon_off" | json_escape)"
    return
  fi

  detect_status
  local status="$current_status"
  local text="$icon_off"
  local class="stopped"
  local tooltip="Docker not running"

  case "$status" in
    active|activating)
      class="running"
      text="$icon_on"
      tooltip="Docker running"
      if cmd_exists docker; then
        mapfile -t containers < <(count_containers || true)
        local count=${#containers[@]}
        if (( count > 0 )); then
          tooltip+=$'\n'"Containers: ${count}"
          for name in "${containers[@]}"; do
            [[ -z "$name" ]] && continue
            tooltip+=$'\n• '"${name}"
          done
        else
          tooltip+=$'\n'"No running containers"
        fi
      else
        tooltip+=$'\n'"docker CLI not found"
      fi
      ;;
    deactivating)
      class="transition"
      tooltip="Docker stopping"
      ;;
    failed)
      class="failed"
      tooltip="Docker failed"
      ;;
    unknown)
      class="unavailable"
      tooltip="Docker status unknown"
      ;;
    *)
      class="stopped"
      tooltip="Docker not running"
      ;;
  esac

  local text_esc tooltip_esc
  text_esc=$(printf '%s' "$text" | json_escape)
  tooltip_esc=$(printf '%s' "$tooltip" | json_escape)

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text_esc" "$class" "$tooltip_esc"
}

toggle_daemon() {
  detect_status
  local status="$current_status"

  if [[ "$status" == "active" || "$status" == "activating" ]]; then
    if ! control_daemon stop >/tmp/waybar-docker-toggle.log 2>&1; then
      send_notification "Failed to stop Docker. Check permissions."
      return 1
    fi
    send_notification "Stopping Docker..."
  else
    if ! control_daemon start >/tmp/waybar-docker-toggle.log 2>&1; then
      send_notification "Failed to start Docker. Check permissions."
      return 1
    fi
    send_notification "Starting Docker..."
  fi
}

case "${1:-}" in
  toggle)
    toggle_daemon
    ;;
  start|stop|restart)
    control_daemon "$1"
    ;;
  *)
    build_output
    ;;
esac
