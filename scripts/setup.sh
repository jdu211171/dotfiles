#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/setup.sh [--restow|--delete] [package ...]

Safely previews and applies GNU Stow actions into $HOME.

Examples:
  scripts/setup.sh hypr waybar git
  scripts/setup.sh --restow hypr nvim
  scripts/setup.sh --delete zsh

Notes:
  - Ensure 'stow' is installed (pacman -S stow | apt install stow | brew install stow)
  - Run from the repo root (~/dotfiles)
USAGE
}

cmd="stow"
mode="apply"
packages=()

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --restow) mode="restow" ;;
    --delete|-D) mode="delete" ;;
    -*) echo "Unknown option: $arg" >&2; usage; exit 2 ;;
    *) packages+=("$arg") ;;
  esac
done

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: 'stow' is not installed."
  echo "Install: pacman -S stow | apt install stow | brew install stow"
  exit 1
fi

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No packages specified; defaulting to common set."
  packages=(hypr waybar kitty nvim zsh git scripts wofi dunst zed oh-my-posh)
fi

target="$HOME"

echo "Previewing actions (dry-run):"
case "$mode" in
  apply)   stow -nv -t "$target"   "${packages[@]}" ;;
  restow)  stow -nv -R -t "$target" "${packages[@]}" ;;
  delete)  stow -nv -D -t "$target" "${packages[@]}" ;;
esac

read -rp $'\nProceed with these changes? [y/N] ' confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

set -x
case "$mode" in
  apply)   stow -v -t "$target"   "${packages[@]}" ;;
  restow)  stow -v -R -t "$target" "${packages[@]}" ;;
  delete)  stow -v -D -t "$target" "${packages[@]}" ;;
esac
set +x

echo "Done."
