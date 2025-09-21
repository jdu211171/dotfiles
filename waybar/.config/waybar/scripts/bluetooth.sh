#!/usr/bin/env bash
set -euo pipefail

icon_bt="󰂯"   # MDI bluetooth
icon_off="󰂲"  # MDI bluetooth-off

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

json_escape() {
  python3 -c 'import json, sys; print(json.dumps(sys.stdin.read(), ensure_ascii=False)[1:-1])'
}

bt_powered() {
  bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2}' | head -n1
}

toggle_power() {
  local p
  p=$(bt_powered || echo "no")
  if [[ "$p" == "yes" ]]; then
    bluetoothctl power off >/dev/null 2>&1 || true
  else
    bluetoothctl power on >/dev/null 2>&1 || true
  fi
}

connected_devices() {
  # Outputs lines: MAC<TAB>Name for connected devices
  bluetoothctl devices 2>/dev/null | awk '{print $2}' | while read -r mac; do
    [[ -z "$mac" ]] && continue
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
      name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/Name:/ {print $2; exit}')
      echo -e "${mac}\t${name}"
    fi
  done
}

device_battery() {
  # Try to parse battery percentage from bluetoothctl info
  local mac="$1"
  bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/Battery Percentage:/ {gsub("%","",$2); print $2; exit}'
}

build_output() {
  if ! cmd_exists bluetoothctl; then
    printf '{"text":"%s","class":"unavailable","tooltip":"bluetoothctl not found"}\n' "$icon_bt"
    return
  fi

  local powered
  powered=$(bt_powered || echo "no")

  local tooltip=""
  local text="$icon_bt"
  local class=""

  if [[ "$powered" != "yes" ]]; then
    class="off"
    text="$icon_off"
    tooltip="Bluetooth powered off"
  else
    # Gather connected devices
    mapfile -t devices < <(connected_devices)
    local count=${#devices[@]}
    if (( count == 0 )); then
      class="disconnected"
      text="$icon_bt"
      tooltip="No devices connected"
    else
      class="connected"
      # Always show only the icon; keep details in tooltip
      text="$icon_bt"
      if (( count == 1 )); then
        mac="${devices[0]%%$'\t'*}"
        name="${devices[0]#*$'\t'}"
        batt=$(device_battery "$mac" || true)
        tooltip="Connected: ${name} (${mac})"$'\n'
        if [[ -n "${batt:-}" ]]; then
          tooltip+="Battery: ${batt}%"
        fi
      else
        tooltip="Connected devices:"$'\n'
        for line in "${devices[@]}"; do
          mac="${line%%$'\t'*}"
          name="${line#*$'\t'}"
          batt=$(device_battery "$mac" || true)
          if [[ -n "${batt:-}" ]]; then
            tooltip+="• ${name} (${batt}%)"$'\n'
          else
            tooltip+="• ${name}"$'\n'
          fi
        done
      fi
    fi
  fi

  # Escape tooltip for JSON
  tooltip_esc=$(printf '%s' "$tooltip" | json_escape)
  text_esc=$(printf '%s' "$text" | json_escape)
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text_esc" "$class" "$tooltip_esc"
}

case "${1:-}" in
  toggle)
    toggle_power
    ;;
  *)
    build_output
    ;;
esac
