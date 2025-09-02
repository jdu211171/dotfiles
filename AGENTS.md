# Agents Guide

This repository is designed for cross‑platform dotfiles (Linux and macOS) managed via GNU Stow. Follow these rules and steps when making changes or bootstrapping a new machine.

## Single‑Repo Rule
- Use this repo as the single source of truth for dotfiles.
- Do not create nested Git repositories inside any package (e.g., no `.git` inside `nvim/.config/nvim`).
- If you must track an external upstream, prefer a Git submodule or copy the files in, then remove `.git` from the imported folder.

## Stow‑Friendly Layout
- Each top‑level directory is a “package” mirroring file paths from `$HOME` down:
  - `nvim/.config/nvim/...`
  - `kitty/.config/kitty/...`
  - `zsh/.zshrc`
  - `git/.gitconfig`
  - `scripts/.local/bin/...`
- `.stow-local-ignore` prevents Stow from linking repo metadata like `.git`, `README.md`, etc.

## Setup With GNU Stow
1) Install Stow
   - Linux: `sudo apt install stow` (Debian/Ubuntu) • `sudo pacman -S stow` (Arch) • `sudo dnf install stow` (Fedora)
   - macOS: `brew install stow`

2) Preview the actions (safe dry‑run)
   - `make -C ~/dotfiles dry-run`
   - Or for specific packages: `make -C ~/dotfiles dry-run PACKAGES="nvim zsh kitty"`

3) Apply symlinks into `$HOME`
   - `make -C ~/dotfiles stow`
   - Or specific packages: `make -C ~/dotfiles stow PACKAGES="nvim zsh kitty"`

4) Update after changes
   - `make -C ~/dotfiles restow`

5) Unlink symlinks
   - `make -C ~/dotfiles unstow`

Notes
- macOS: skip Linux‑only packages (e.g., `hypr`, `waybar`, `wofi`, `dunst`). Common packages like `nvim`, `zsh`, `kitty`, `git`, `scripts`, `oh-my-posh`, and `zed` work on both.
- If Stow reports conflicts (existing non‑symlink files), move those files into the appropriate package in this repo, then run `restow`.
- Per‑host overrides (e.g., `host-laptop`) should be stowed only on the relevant machine.

## Commit Conventions
- Normal changes should use clear, scoped messages (e.g., `nvim: add treesitter config`).
- Bulk migrations or syncs may use a clearly “noisy” message to stand out (e.g., `NOISY SYNC: merge local ~/dotfiles …`).

## Ignore and Noise Hygiene
- Avoid committing OS and cache files (already covered in `.gitignore`): `.DS_Store`, `Thumbs.db`, `node_modules/`, `.idea/`, `.vscode/`, etc.
- Never commit secrets. If a file must contain secrets locally, template it here (e.g., `*.example`) and keep real values out of the repo.
