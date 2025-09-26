Hotspot (Wi‑Fi Tethering) on Arch with NetworkManager

Overview
- Uses NetworkManager AP mode with ipv4.method=shared (DHCP/DNS via dnsmasq, NAT).
- Auto-starts hotspot when Ethernet connects via a NetworkManager dispatcher hook.
- Optional user service mirrors behavior for desktop sessions.

Requirements
- Packages: networkmanager, dnsmasq. Optional: iw, firewalld.
- Enable services: `sudo systemctl enable --now NetworkManager` (plus `firewalld` if used).
- Hardware: Wi‑Fi card that supports AP mode (`iw list` shows “AP”).

Packages to stow
- `scripts`, `systemd`, and `autohotspot` into `$HOME`.

Quick Start (new install)
1) Install OS packages:
   - `sudo pacman -S networkmanager dnsmasq` (optional: `iw firewalld`)
   - `sudo systemctl enable --now NetworkManager`

2) Stow user files:
   - `make -C ~/dotfiles stow PACKAGES="scripts systemd autohotspot"`

3) Configure local SSID/PSK:
   - `cp ~/dotfiles/autohotspot/.config/autohotspot.env.example ~/.config/autohotspot.env`
   - Edit `~/.config/autohotspot.env` (set `HOTSPOT_SSID`, `HOTSPOT_PSK`, band/channel or interfaces as needed)

4) Install dispatcher (root‑owned, required for autostart):
   - `autohotspot-install`
     - Copies dispatcher to `/etc/NetworkManager/dispatcher.d/50-autohotspot.sh` (no symlink)
     - Writes `/etc/NetworkManager/autohotspot.env`
     - Ensures IPv4 forwarding via `/etc/sysctl.d/99-autohotspot-forward.conf`
     - Restarts NetworkManager

5) Bring hotspot up (two options):
   - Auto: plug Ethernet; dispatcher will start the hotspot.
   - Manual: `hotspot-up` (and `hotspot-down` to stop).

6) Optional (firewalld zones, robust):
   - `sudo pacman -S firewalld && sudo systemctl enable --now firewalld`
   - `nmcli con mod "Wired connection 1" connection.zone external`
   - `nmcli con mod dotfiles-hotspot connection.zone internal`
   - `sudo firewall-cmd --reload`

Known Pitfalls & Fixes
- dnsmasq missing → Install `dnsmasq` (NM uses its own instance).
- SSID not visible on Apple devices → Force 2.4 GHz `band=bg` and `channel=1/6/11`.
- No internet despite connection → Default FORWARD policy may be drop; firewalld zones or nftables forward allow rules fix it.
- Dispatcher ignored → Must be a root‑owned regular file in `/etc/NetworkManager/dispatcher.d`, not a symlink; use `autohotspot-install`.

Manual Commands (reference)
- Create/modify hotspot profile:
  - `nmcli con modify dotfiles-hotspot 802-11-wireless.mode ap 802-11-wireless.band bg 802-11-wireless-security.key-mgmt wpa-psk 802-11-wireless-security.psk 'changeme' ipv4.method shared ipv6.method ignore`
- Start/stop:
  - `hotspot-up` / `hotspot-down`
- Firewall (without firewalld):
  - NAT: `sudo nft add table inet nm-shared; sudo nft add chain inet nm-shared post '{ type nat hook postrouting priority srcnat; }'; sudo nft add rule inet nm-shared post oifname <ethernet> ip saddr 10.42.0.0/24 masquerade`
  - Forward: `sudo nft add chain inet filter forward '{ type filter hook forward priority 0; }'; sudo nft add rule inet filter forward iifname <wifi> oifname <ethernet> accept; sudo nft add rule inet filter forward iifname <ethernet> oifname <wifi> ct state related,established accept`

Troubleshooting
- Check hotspot active: `nmcli -t -f NAME,TYPE,DEVICE con show --active | rg dotfiles-hotspot`
- AP IP: `ip -4 addr show wlan0`
- Logs: `journalctl -b -u NetworkManager | rg -i 'dnsmasq|shared4|wlan0'`
- AP support: `iw list | rg '^\s+AP$' -n` (requires `iw`)

