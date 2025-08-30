# Dotfiles (GNU Stow)

This repo manages my configs with GNU Stow. Each package mirrors paths from $HOME downward and is symlinked into place.

## Layout

- hypr/.config/hypr/hyprland.conf
- waybar/.config/waybar/config.jsonc
- kitty/.config/kitty/kitty.conf
- nvim/.config/nvim/init.lua
- zed/.config/zed/{settings.json,keymap.json}
- zsh/.zshrc
- git/.gitconfig
- scripts/.local/bin/...
- wofi/.config/wofi/config
- dunst/.config/dunst/dunstrc
- oh-my-posh/.config/oh-my-posh/theme.omp.json
- host-laptop/.config/hypr/host.conf (optional per-host overrides)

## Usage

1) Install Stow: pacman -S stow (Arch), apt install stow, or brew install stow

2) Dry-run to preview links:

    make -C dotfiles dry-run

3) Apply symlinks into $HOME:

    make -C dotfiles stow

- Restow after changes:

    make -C dotfiles restow

- Unstow to remove symlinks:

    make -C dotfiles unstow

You can target specific packages with PACKAGES:

    make -C dotfiles stow PACKAGES="hypr waybar git zed oh-my-posh"

## Notes

- If Stow reports an existing non-symlink file conflict, move that file into this repo under the matching package and rerun with restow.
- .stow-local-ignore prevents Stow from linking repo meta files like .git and README.md.
- For host-specific tweaks (e.g., laptop vs desktop), include host-laptop and only stow it on that machine.

## Bootstrap script

See scripts/setup.sh for a safe helper that previews and applies stow actions.
Make it executable once: chmod +x scripts/setup.sh
