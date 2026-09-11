# Dotfiles (GNU Stow)

This repo manages my configs with GNU Stow. Each package mirrors paths from $HOME downward and is symlinked into place.

Canonical location on this machine: ~/dotfiles

## Layout

- hypr/.config/hypr/hyprland.conf
- waybar/.config/waybar/config.jsonc
- kitty/.config/kitty/kitty.conf
- herdr/.config/herdr/{config.toml,manual.md}
- nvim/.config/nvim/init.lua
- zed/.config/zed/{settings.json,keymap.json}
- zsh/.zshrc
- git/.gitconfig
- kiro/.kiro/settings/permissions.yaml
- scripts/.local/bin/...
- wofi/.config/wofi/config
- dunst/.config/dunst/dunstrc
- oh-my-posh/.config/oh-my-posh/theme.omp.json
- herdr/.config/herdr/config.toml
- codex/.codex/config.toml
- gemini/.gemini/{settings.json,GEMINI.md,...}
- host-laptop/.config/hypr/host.conf (optional per-host overrides)

GitHub may collapse hidden path segments in the file browser. The Neovim
package lives under `nvim/.config/nvim/`, not directly under `nvim/`.

## Usage

1. Install Stow: pacman -S stow (Arch), apt install stow, or brew install stow

2. Dry-run to preview links:

   make -C ~/dotfiles dry-run

3. Apply symlinks into $HOME:

   make -C ~/dotfiles stow

- Restow after changes:

  make -C ~/dotfiles restow

- Unstow to remove symlinks:

  make -C ~/dotfiles unstow

You can target specific packages with PACKAGES:

    make -C ~/dotfiles stow PACKAGES="hypr waybar git zed oh-my-posh"

## Notes

- If Stow reports an existing non-symlink file conflict, move that file into this repo under the matching package and rerun with restow.
- .stow-local-ignore prevents Stow from linking repo meta files like .git and README.md.
- For host-specific tweaks (e.g., laptop vs desktop), include host-laptop and only stow it on that machine.
- Shared shell history (bash + zsh): see docs/shared-history.md

## Hotspot (tethering) on Arch

- See docs/hotspot.md for a detailed guide.
- Requirements: `networkmanager` enabled, `dnsmasq`, polkit agent, AP‑capable Wi‑Fi card.
- Tools provided:
  - Scripts: `hotspot-setup`, `hotspot-up`, `hotspot-down`, `nm-hotspot-autostart`, `autohotspot-install`.
  - User service: `systemd/.config/systemd/user/nm-hotspot-autostart.service`.
  - Dispatcher hook (installed by `autohotspot-install`).

Fresh install quick start:

    sudo pacman -S networkmanager dnsmasq
    sudo systemctl enable --now NetworkManager
    make stow PACKAGES="scripts systemd autohotspot"
    autohotspot-install
    # edit ~/.config/autohotspot.env to set SSID/PSK if needed
    hotspot-up   # or just plug Ethernet to auto-start via dispatcher

## Bootstrap script

See scripts/setup.sh for a safe helper that previews and applies stow actions.
Make it executable once: chmod +x scripts/setup.sh

## gstack (AI agent skills for Codex + Kiro CLI)

[gstack](https://github.com/garrytan/gstack) is a suite of opinionated skills for
AI coding agents. It is installed per-machine (not stowed) because its skills are
machine-generated and symlink into an upstream clone. The tracked, reproducible
artifact is `scripts/.local/bin/gstack-install`.

Install/refresh for the default hosts (Codex + Kiro CLI):

    gstack-install

Other usage:

    gstack-install codex            # only Codex
    gstack-install kiro codex       # explicit host list
    gstack-install --no-update      # skip git pull on the existing clone
    gstack-install --ref v1.84.1.0  # pin a specific tag/branch/commit

What it does:

- Clones (or updates) the upstream to `~/gstack` (override with `GSTACK_DIR`).
- Runs `./setup --host <agent>` for each requested host. Skills land in
  `${CODEX_HOME:-~/.codex}/skills/gstack-*` and `~/.kiro/skills/gstack-*`.
- Exports `GSTACK_CHROMIUM_NO_SANDBOX=1` so the bundled browser can launch on
  Ubuntu 24.04+ (AppArmor restricts unprivileged user namespaces).

Notes:

- The generated `gstack-*` skill dirs are intentionally not tracked in this repo
  (see the gstack block in `.gitignore`). Only this bootstrap script is tracked.
- Requirements: `git`, `bun` (v1.0+), and `node` for the browser skills.
- The bundled Chromium is optional; if it fails to download, all non-browser
  skills still work. Re-run `gstack-install` after fixing the cause.
