#!/usr/bin/env bash
set -euo pipefail

# NetworkManager dispatcher hook to start/stop a hotspot when Ethernet goes up/down.
# Place as /etc/NetworkManager/dispatcher.d/50-autohotspot.sh and make executable.
# Reads configuration from /etc/NetworkManager/autohotspot.env if present.

ENV_FILE=/etc/NetworkManager/autohotspot.env
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1091
  source "$ENV_FILE"
fi

HOTSPOT_CON=${HOTSPOT_CON:-dotfiles-hotspot}
HOTSPOT_WIFI_IF=${HOTSPOT_WIFI_IF:-}
HOTSPOT_WIRE_IF=${HOTSPOT_WIRE_IF:-}
HOTSPOT_BAND=${HOTSPOT_BAND:-bg}
HOTSPOT_CHANNEL=${HOTSPOT_CHANNEL:-auto}
HOTSPOT_SSID=${HOTSPOT_SSID:-arch-hotspot}
HOTSPOT_PSK=${HOTSPOT_PSK:-changeme-please}

iface="$1"      # interface name
action="$2"     # up|down|pre-up|pre-down|... per NM docs

log(){ logger -t autohotspot "$*"; }

is_eth() {
  nmcli -t -f DEVICE,TYPE device | grep -Fxq "$iface:ethernet"
}

ensure_connection() {
  if nmcli -t -f NAME connection show | grep -Fxq "$HOTSPOT_CON"; then
    return 0
  fi

  local wifi_if="$HOTSPOT_WIFI_IF"
  if [[ -z "$wifi_if" ]]; then
    wifi_if=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi" {print $1; exit}') || true
  fi
  if [[ -z "$wifi_if" ]]; then
    log "No Wi-Fi interface found; cannot create hotspot connection."
    return 1
  fi

  nmcli connection add type wifi ifname "$wifi_if" con-name "$HOTSPOT_CON" ssid "$HOTSPOT_SSID"
  nmcli connection modify "$HOTSPOT_CON" \
    802-11-wireless.mode ap \
    802-11-wireless.band "$HOTSPOT_BAND" \
    ipv4.method shared \
    ipv6.method ignore \
    connection.autoconnect no

  if [[ "$HOTSPOT_CHANNEL" != "auto" ]]; then
    nmcli connection modify "$HOTSPOT_CON" 802-11-wireless.channel "$HOTSPOT_CHANNEL"
  fi

  nmcli connection modify "$HOTSPOT_CON" \
    802-11-wireless-security.key-mgmt wpa-psk \
    802-11-wireless-security.psk "$HOTSPOT_PSK"
}

case "$action" in
  up)
    if is_eth && { [[ -z "$HOTSPOT_WIRE_IF" ]] || [[ "$iface" == "$HOTSPOT_WIRE_IF" ]]; }; then
      ensure_connection || exit 0
      log "Ethernet up on $iface: starting hotspot $HOTSPOT_CON"
      nmcli connection up "$HOTSPOT_CON" || log "Failed to start hotspot"
      # NAT/DHCP are normally handled by NetworkManager when ipv4.method=shared.
      # Some environments lack automatic masquerade rules. Add a safe fallback.
      (
        set -e
        # Enable IPv4 forwarding (non-persistent; NM usually does this too)
        sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
        # Discover upstream and hotspot subnets/interfaces
        up_if="$iface"
        hs_if=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi" {print $1; exit}')
        hs_subnet="10.42.0.0/24"
        # Prefer nft if available; otherwise iptables
        if command -v nft >/dev/null 2>&1; then
          # NAT (postrouting masquerade)
          nft list ruleset 2>/dev/null | grep -q 'table inet nm-shared' || nft add table inet nm-shared || true
          nft list chain inet nm-shared post 2>/dev/null >/dev/null || nft 'add chain inet nm-shared post { type nat hook postrouting priority srcnat; }' || true
          nft list ruleset 2>/dev/null | grep -q "oifname \"$up_if\" ip saddr 10.42.0.0/24 masquerade" || \
            nft add rule inet nm-shared post oifname "$up_if" ip saddr 10.42.0.0/24 masquerade || true

          # Filter forwarding allow (only if a forward base chain exists or create one)
          nft list chain inet nm-shared fwdchain 2>/dev/null >/dev/null || nft 'add chain inet nm-shared fwdchain { type filter hook forward priority 0; }' || true
          nft list ruleset 2>/dev/null | grep -q "iifname \"$hs_if\" oifname \"$up_if\" accept" || \
            nft add rule inet nm-shared fwdchain iifname "$hs_if" oifname "$up_if" accept || true
          nft list ruleset 2>/dev/null | grep -q "iifname \"$up_if\" oifname \"$hs_if\" ct state related,established accept" || \
            nft add rule inet nm-shared fwdchain iifname "$up_if" oifname "$hs_if" ct state related,established accept || true
        elif command -v iptables >/dev/null 2>&1; then
          iptables -C FORWARD -i "$up_if" -o "$hs_if" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
            iptables -A FORWARD -i "$up_if" -o "$hs_if" -m state --state RELATED,ESTABLISHED -j ACCEPT || true
          iptables -C FORWARD -i "$hs_if" -o "$up_if" -j ACCEPT 2>/dev/null || \
            iptables -A FORWARD -i "$hs_if" -o "$up_if" -j ACCEPT || true
          iptables -t nat -C POSTROUTING -s "$hs_subnet" -o "$up_if" -j MASQUERADE 2>/dev/null || \
            iptables -t nat -A POSTROUTING -s "$hs_subnet" -o "$up_if" -j MASQUERADE || true
        fi
      ) || log "NAT fallback setup encountered an error"
    fi
    ;;
  down)
    if is_eth && { [[ -z "$HOTSPOT_WIRE_IF" ]] || [[ "$iface" == "$HOTSPOT_WIRE_IF" ]]; }; then
      log "Ethernet down on $iface: stopping hotspot $HOTSPOT_CON"
      nmcli connection down "$HOTSPOT_CON" || true
    fi
    ;;
esac
